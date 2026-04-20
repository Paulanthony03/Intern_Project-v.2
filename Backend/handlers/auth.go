package handlers

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	config "student-system/config"
	"student-system/models"
	"student-system/utils"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func Register(c *gin.Context) {
	var user models.User

	// Bind JSON
	if err := c.BindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var existingUser models.User
	config.DB.Where("email = ?", user.Email).First(&existingUser)

	if existingUser.ID != 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Email already exists",
		})
		return
	}
	user.Role = "user"
	// Hash password
	hash, _ := bcrypt.GenerateFromPassword([]byte(user.Password), 14)
	user.Password = string(hash)

	result := config.DB.Create(&user)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to register user",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "User registered",
	})

}

func Login(c *gin.Context) {
	var input models.User
	var user models.User

	if err := c.BindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	config.DB.Where("email = ?", input.Email).First(&user)

	if user.ID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Wrong password"})
		return
	}

	token, _ := utils.GenerateToken(user.ID)

	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user": gin.H{
			"id":    user.ID,
			"name":  user.Name,
			"email": user.Email,
			"role":  user.Role,
		},
	})
}

func ForgotPassword(c *gin.Context) {
	var req struct {
		Email string `json:"email"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// 1. Check if user exists
	email := strings.TrimSpace(strings.ToLower(req.Email))
	fmt.Println("INPUT:", req.Email)
	fmt.Println("NORMALIZED:", email)

	var users []models.User
	config.DB.Find(&users)

	for _, u := range users {
		fmt.Println("DB:", u.Email)
	}
	var user models.User

	err := config.DB.
		Where("email = ?", email).
		First(&user).Error

	if err != nil {
		c.JSON(404, gin.H{"error": "Email not found"})
		return
	}

	// 2. Generate OTP
	otp := utils.GenerateOTP()
	expiry := time.Now().Add(5 * time.Minute)

	// 3. Save OTP
	otpRecord := models.OTPCode{
		Email:     email,
		OTP:       otp,
		ExpiresAt: expiry,
		Verified:  false,
	}

	config.DB.Create(&otpRecord)

	// 4. Send email
	utils.SendOTPEmail(req.Email, otp)

	c.JSON(http.StatusOK, gin.H{"message": "OTP sent successfully"})
}

func VerifyOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}

	var otpRecord models.OTPCode

	err := config.DB.
		Where("email = ?", req.Email).
		Order("created_at DESC").
		First(&otpRecord).Error

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP not found"})
		return
	}

	if otpRecord.OTP != req.OTP || time.Now().After(otpRecord.ExpiresAt) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or expired OTP"})
		return
	}

	// mark verified
	config.DB.Model(&otpRecord).Update("verified", true)

	c.JSON(http.StatusOK, gin.H{"message": "OTP verified"})
}

func ResetPassword(c *gin.Context) {
	var req struct {
		Email       string `json:"email"`
		NewPassword string `json:"new_password"`
	}

	// check latest OTP verified
	var otpRecord models.OTPCode

	err := config.DB.
		Where("email = ? AND verified = ?", req.Email, true).
		Order("created_at DESC").
		First(&otpRecord).Error

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP not verified"})
		return
	}

	hashed, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to hash password"})
		return
	}

	config.DB.Model(&models.User{}).
		Where("email = ?", req.Email).
		Update("password", hashed)

	c.JSON(http.StatusOK, gin.H{"message": "Password reset successful"})

}
func DeleteUser(c *gin.Context) {
	id := c.Param("id")

	var user models.User
	if err := config.DB.First(&user, id).Error; err != nil {
		c.JSON(404, gin.H{"error": "User not found"})
		return
	}

	config.DB.Delete(&user)

	c.JSON(200, gin.H{"message": "User deleted successfully"})
}
