package main

import "fmt"

type BoardCastMessage struct {
	Target  string
	Message string
}

type Hub struct {
	clients    map[*Client]bool
	register   chan *Client
	unregister chan *Client
	boardcast  chan *BoardCastMessage
}

func newHub() *Hub {
	return &Hub{
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
		boardcast:  make(chan *BoardCastMessage),
	}
}

func (h *Hub) run() {
	for {
		select {
		case client := <-h.register:
			h.clients[client] = true
			CommonClientsMap[client.target]++
			go func() {
				h.boardcast <- &BoardCastMessage{
					Target:  client.target,
					Message: fmt.Sprintf(`{"type":"hb","alive":%d}`, CommonClientsMap[client.target]),
				}
			}()
		case client := <-h.unregister:
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.send)
				CommonClientsMap[client.target]--
				go func() {
					h.boardcast <- &BoardCastMessage{
						Target:  client.target,
						Message: fmt.Sprintf(`{"type":"hb","alive":%d}`, CommonClientsMap[client.target]),
					}
				}()
				if CommonClientsMap[client.target] == 0 {
					delete(CommonClientsMap, client.target)
				}
			}
		case msg := <-h.boardcast:
			for i := range h.clients {
				if i.target == msg.Target {
					i.send <- []byte(msg.Message)
				}
			}
		}
	}
}
