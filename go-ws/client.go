package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/websocket"
)

const (
	writeWait      = 5 * time.Second
	maxMessageSize = 512
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

type Client struct {
	hub    *Hub
	conn   *websocket.Conn
	send   chan []byte
	target string
}

func AuthWSClient(token string) bool {
	return true
}

var CommonClientsMap = make(map[string]int)

func (c *Client) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()
	c.conn.SetReadLimit(maxMessageSize)
	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			break
		}
		// client should never send any message to server
		fmt.Println("Client try to send message", message)
		c.hub.unregister <- c
	}
}

func (c *Client) writePump() {
	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write(<-c.send)
			}
			if err := w.Close(); err != nil {
				return
			}
		}
	}
}

func CheckMAC(msg, msgMAC, key []byte) bool {
	mac := hmac.New(sha256.New, key)               // 创建hash加密算法
	mac.Write(msg)                                 // 写入数据
	expectedMAC := fmt.Sprintf("%x", mac.Sum(nil)) //获取加密后的hash
	return expectedMAC == string(msgMAC)           // 比较预期的hash和实际的hash
}

func CheckTime(timestr string) bool {
	// Check timestamp
	timestamp, err := strconv.Atoi(timestr)
	if err != nil {
		log.Println("Invalid Timestamp:", timestr)
		return false
	}
	now := time.Now().Unix()
	if now-int64(timestamp) > 60*3 { // 3  minutes
		log.Println("Outdated token :", now-int64(timestamp))
		return false
	}
	return true
}

func serveWs(hub *Hub, w http.ResponseWriter, r *http.Request) {
	// auth hmac
	reqURI := strings.Split(r.RequestURI, "/")
	if len(reqURI) != 3 || len(reqURI[1]) <= 20 {
		log.Println("Invalid websocket request:", reqURI)
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	wsAuthString, wsClassTarget, wsHMACToken := reqURI[1], string(reqURI[1][15]), reqURI[2]
	if !CheckTime(wsAuthString[16:]) {
		fmt.Println("Token timestamp error.")
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	if !CheckMAC([]byte(wsAuthString), []byte(wsHMACToken), []byte("as0wD7Bx$Xozq9QSLaRaD3qVCO")) {
		log.Println("Invalid HMAC!")
		w.WriteHeader(http.StatusForbidden)
		return
	}
	fmt.Println(wsAuthString, wsHMACToken, wsClassTarget)
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	client := &Client{hub: hub, conn: conn, send: make(chan []byte, 256), target: wsClassTarget}
	client.hub.register <- client
	go client.writePump()
	go client.readPump()
}
