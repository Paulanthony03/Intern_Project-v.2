package controllers

import (
	"strings"

	"github.com/gin-gonic/gin"
)

func SendRegistrationOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Valid email required"})
		return
	}

	email := strings.TrimSpace(strings.ToLower(req.Email))

	otp, _ := generateOTP()

	db.Exec("DELETE FROM email_verifications WHERE email=$1", email)

	db.Exec(`
		INSERT INTO email_verifications (email, otp, expires_at)
		VALUES ($1, $2, NOW() + INTERVAL '10 minutes')
	`, email, otp)

	sendOTPEmail(email, otp)

	c.JSON(200, gin.H{"message": "OTP sent for registration"})
}

func VerifyRegistrationOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
		OTP   string `json:"otp" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": "Invalid request"})
		return
	}

	email := strings.TrimSpace(strings.ToLower(req.Email))

	var dbOTP string

	err := db.QueryRow(`
		SELECT otp FROM email_verifications
		WHERE email = $1
		ORDER BY id DESC LIMIT 1
	`, email).Scan(&dbOTP)

	if err != nil || dbOTP != req.OTP {
		c.JSON(400, gin.H{"error": "Invalid OTP"})
		return
	}

	db.Exec(`
		UPDATE email_verifications
		SET verified = true
		WHERE email = $1
	`, email)

	c.JSON(200, gin.H{"message": "Email verified"})
}
