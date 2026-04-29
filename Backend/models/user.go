package models

import "time"

type User struct {
	ID          uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	Name        string    `json:"name"`
	Email       string    `json:"email" gorm:"uniqueIndex"`
	Password    string    `json:"password"`
	InternID    string    `json:"intern_id" gorm:"column:intern_id"`
	School      string    `json:"school"`
	Contact     string    `json:"contact"`
	Department  string    `json:"department"`
	Role        string    `json:"role" gorm:"default:user"`
	RoleID      int       `json:"role_id" gorm:"default:1"`
	ResetToken  string    `json:"reset_token"`
	TokenExpiry time.Time `json:"token_expiry"`
	PhotoURL    string    `json:"photo_url" gorm:"column:photo_url"`
	IsDeleted   bool      `json:"is_deleted" gorm:"default:false"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
