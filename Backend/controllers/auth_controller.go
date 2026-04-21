package controllers

import (
	"crypto/rand"
	"database/sql"
	"fmt"
	"math/big"
	"net/http"
	"net/smtp"
	"strings"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

var db *sql.DB

func SetDB(database *sql.DB) {
	db = database
}

const smtpHost = "smtp.gmail.com"
const smtpPort = "587"

var smtpEmail = "polanthony0345@gmail.com"
var smtpPassword = "idukxxrmbqepxefv"

// ================= HELPERS =================

func generateOTP() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1000000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

func sendOTPEmail(toEmail, otp string) error {

	subject := "Subject: Password Reset OTP\r\n"

	body := fmt.Sprintf(`
		<h3>Password Reset Request</h3>
		<p>Your OTP is: <b>%s</b></p>
	`, otp)

	message := []byte(subject +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n" +
		body)

	auth := smtp.PlainAuth(
		"",
		smtpEmail,
		smtpPassword,
		"smtp.gmail.com",
	)

	err := smtp.SendMail(
		smtpHost+":"+smtpPort,
		auth,
		smtpEmail,
		[]string{toEmail},
		message,
	)

	if err != nil {
		fmt.Println("SMTP ERROR:", err)
		return err
	}

	fmt.Println("EMAIL SENT SUCCESSFULLY")
	return nil
}

// ================= HANDLERS =================

func ForgotPasswordHandler(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Valid email is required"})
		return
	}

	email := strings.TrimSpace(strings.ToLower(req.Email))

	var exists bool
	db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)", email).Scan(&exists)

	if !exists {
		c.JSON(http.StatusOK, gin.H{"message": "If email exists, OTP was sent"})
		return
	}

	otp, _ := generateOTP()
	db.Exec("DELETE FROM forgot_password_requests WHERE email=$1", email)
	db.Exec("INSERT INTO forgot_password_requests (email, otp, expires_at) VALUES ($1, $2, NOW() + INTERVAL '10 minutes')", email, otp)

	err := sendOTPEmail(email, otp)
	if err != nil {
		fmt.Println("❌ EMAIL ERROR:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send email"})
		return
	}

	fmt.Println("✅ EMAIL SENT SUCCESSFULLY")

	c.JSON(http.StatusOK, gin.H{"message": "OTP sent to email"})
}

func VerifyOTPHandler(c *gin.Context) {

	var req struct {
		Email string `json:"email" binding:"required"`
		OTP   string `json:"otp" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	email := strings.TrimSpace(strings.ToLower(req.Email))
	otp := strings.TrimSpace(req.OTP)

	var dbOTP string
	var used bool
	var expiresAt string

	// Get latest OTP record
	err := db.QueryRow(`
		SELECT otp, used, expires_at
		FROM forgot_password_requests
		WHERE email = $1
		ORDER BY id DESC
		LIMIT 1
	`, email).Scan(&dbOTP, &used, &expiresAt)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP not found"})
		return
	}

	// check if already used
	if used {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP already used"})
		return
	}

	// check OTP match
	if otp != dbOTP {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid OTP"})
		return
	}

	// mark as verified (optional but recommended)
	_, err = db.Exec(`
		UPDATE forgot_password_requests
		SET used = true
		WHERE email = $1 AND otp = $2
	`, email, otp)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify OTP"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "OTP verified successfully",
	})
}

func ResetPasswordHandler(c *gin.Context) {

	var req struct {
		Email       string `json:"email" binding:"required"`
		NewPassword string `json:"new_password" binding:"required,min=8"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	req.Email = strings.TrimSpace(strings.ToLower(req.Email))

	// 1. Check if OTP was already verified
	var used bool

	err := db.QueryRow(`
		SELECT used
		FROM forgot_password_requests
		WHERE email = $1
		ORDER BY id DESC
		LIMIT 1
	`, req.Email).Scan(&used)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No OTP verification found"})
		return
	}

	if !used {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP not verified"})
		return
	}

	// 2. Hash new password
	hashed, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// 3. Update user password
	result, err := db.Exec(`
		UPDATE users
		SET password = $1
		WHERE email = $2
	`, string(hashed), req.Email)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
		return
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User not found"})
		return
	}

	// 4. Clean up OTP record (optional but recommended)
	db.Exec(`
		DELETE FROM forgot_password_requests
		WHERE email = $1
	`, req.Email)

	c.JSON(http.StatusOK, gin.H{
		"message": "Password reset successful",
	})
}
