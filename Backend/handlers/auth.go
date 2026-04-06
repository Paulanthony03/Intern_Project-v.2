package handlers

import (
	"net/http"
	"student-system/config"
	"student-system/models"
	"student-system/utils"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func Register(c *gin.Context) {
	var user models.User

	// 1. Bind JSON
	if err := c.BindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 🔥 STEP 3: CHECK IF EMAIL EXISTS (PUT HERE)
	var existingUser models.User
	config.DB.Where("email = ?", user.Email).First(&existingUser)

	if existingUser.ID != 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Email already exists",
		})
		return
	}

	// 2. Hash password
	hash, _ := bcrypt.GenerateFromPassword([]byte(user.Password), 14)
	user.Password = string(hash)

	// 🔥 STEP 4: CREATE USER (PUT HERE)
	result := config.DB.Create(&user)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to register user",
		})
		return
	}

	// 3. Success response
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
