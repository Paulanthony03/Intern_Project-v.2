package models

import "time"

type Attendance struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"index"`
	Date      string    `json:"date" gorm:"index"` // Format: "YYYY-MM-DD"
	Status    string    `json:"status"`            // "present" or "absent"
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
