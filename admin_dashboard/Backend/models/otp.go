package models

import "time"

type OTPCode struct {
	ID        uint `gorm:"primaryKey"`
	Email     string
	OTP       string
	ExpiresAt time.Time
	Verified  bool
	CreatedAt time.Time
}
