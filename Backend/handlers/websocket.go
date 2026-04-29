package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for development
	},
}

// Hub manages WebSocket connections and broadcasts
type Hub struct {
	clients    map[uint]*websocket.Conn
	clientsMux sync.RWMutex
}

var WS = &Hub{
	clients: make(map[uint]*websocket.Conn),
}

type WSMessage struct {
	Type string      `json:"type"`
	Data interface{} `json:"data"`
}

func (h *Hub) Register(userID uint, conn *websocket.Conn) {
	h.clientsMux.Lock()
	// Close existing connection for this user if any
	if old, exists := h.clients[userID]; exists {
		old.Close()
	}
	h.clients[userID] = conn
	h.clientsMux.Unlock()
	log.Printf("WebSocket: user %d connected", userID)
}

func (h *Hub) Unregister(userID uint) {
	h.clientsMux.Lock()
	if conn, exists := h.clients[userID]; exists {
		conn.Close()
		delete(h.clients, userID)
	}
	h.clientsMux.Unlock()
	log.Printf("WebSocket: user %d disconnected", userID)
}

func (h *Hub) Broadcast(msg WSMessage) {
	h.clientsMux.RLock()
	defer h.clientsMux.RUnlock()

	payload, err := json.Marshal(msg)
	if err != nil {
		return
	}

	for userID, conn := range h.clients {
		err := conn.WriteMessage(websocket.TextMessage, payload)
		if err != nil {
			log.Printf("WebSocket: failed to send to user %d: %v", userID, err)
		}
	}
}

func (h *Hub) SendToUser(userID uint, msg WSMessage) {
	h.clientsMux.RLock()
	conn, exists := h.clients[userID]
	h.clientsMux.RUnlock()

	if !exists {
		return
	}

	payload, err := json.Marshal(msg)
	if err != nil {
		return
	}

	conn.WriteMessage(websocket.TextMessage, payload)
}

func HandleWebSocket(c *gin.Context) {
	userID := c.GetUint("user_id")
	if userID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Authentication required"})
		return
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("WebSocket upgrade failed: %v", err)
		return
	}

	WS.Register(userID, conn)

	// Keep connection alive and listen for close
	defer WS.Unregister(userID)

	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error for user %d: %v", userID, err)
			}
			break
		}
	}
}

// BroadcastUserCreated sends notification when a new user is created
func BroadcastUserCreated(user interface{}) {
	WS.Broadcast(WSMessage{
		Type: "user_created",
		Data: user,
	})
}

// BroadcastUserUpdated sends notification when a user is updated
func BroadcastUserUpdated(user interface{}) {
	WS.Broadcast(WSMessage{
		Type: "user_updated",
		Data: user,
	})
}

// BroadcastUserDeleted sends notification when a user is deleted
func BroadcastUserDeleted(userID string) {
	WS.Broadcast(WSMessage{
		Type: "user_deleted",
		Data: gin.H{"id": userID},
	})
}
