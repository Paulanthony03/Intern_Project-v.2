package handlers

import (
	"fmt"
	"net/http"
	"time"

	"student-system/config"
	"student-system/models"
	"student-system/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
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
	// Success response
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

	if err := c.BindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	fmt.Println("Forgot Password called")

	var user models.User
	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		fmt.Println("User not found:", err)
		c.JSON(404, gin.H{"error": "User not found"})
		return
	}

	token := uuid.New().String()

	user.ResetToken = token
	user.TokenExpiry = time.Now().Add(15 * time.Minute)

	if err := config.DB.Save(&user).Error; err != nil {
		fmt.Println("DB save error:", err)
		c.JSON(500, gin.H{"error": "DB error"})
		return
	}

	resetLink := "myapp://reset?token=" + token
	body := "Click to reset password:\n\n" + resetLink

	err := utils.SendEmail(user.Email, "Reset Password", body)
	if err != nil {
		c.JSON(500, gin.H{"error": "Email failed"})
		return
	}

	c.JSON(200, gin.H{
		"message": "Reset link sent",
		"token":   token,
	})
}

func ResetPassword(c *gin.Context) {
	var req struct {
		Token       string `json:"token"`
		NewPassword string `json:"password"`
	}

	c.BindJSON(&req)

	var user models.User
	if err := config.DB.Where("reset_token = ?", req.Token).First(&user).Error; err != nil {
		c.JSON(400, gin.H{"error": "Invalid token"})
		return
	}

	if time.Now().After(user.TokenExpiry) {
		c.JSON(400, gin.H{"error": "Token expired"})
		return
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.NewPassword), 10)

	user.Password = string(hashed)
	user.ResetToken = ""
	user.TokenExpiry = time.Time{}

	if err := config.DB.Save(&user).Error; err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "Password updated"})
}
