package models

import "time"

type User struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	Name        string    `json:"name"`
	Email       string    `json:"email" gorm:"uniqueIndex"`
	Password    string    `json:"password"`
	InternID    string    `json:"intern_id"`
	School      string    `json:"school"`
	Role        string    `json:"role" gorm:"default:user"`
	ResetToken  string    `json:"reset_token"`
	TokenExpiry time.Time `json:"token_expiry"`
}
