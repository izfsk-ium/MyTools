package main

import (
	"log"
	"net/http"
	"strings"
)

func main() {
	hub := newHub()
	go hub.run()
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.RemoteAddr, "127.0.0.1") && r.URL.Path == "/rpc/notify" {
			// the notify send RPC api
			go func() {
				log.Println("Send message to target group", r.Header.Get("target"))
				hub.boardcast <- &BoardCastMessage{
					Target:  r.Header.Get("target"),
					Message: r.Header.Get("message"),
				}
			}()
			w.WriteHeader(http.StatusOK)
		} else {
			serveWs(hub, w, r)
		}
	})
	error := http.ListenAndServe("127.0.0.1:8080", nil)
	if error != nil {
		log.Fatal("ListenAndServe: ", error)
	}
}
