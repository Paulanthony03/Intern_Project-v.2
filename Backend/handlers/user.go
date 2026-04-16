package handlers

import (
	"log"
	"net/http"
	"strings"
	config "student-system/config"
	"student-system/models"

	"github.com/gin-gonic/gin"
)

func GetProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	var user models.User
	config.DB.First(&user, userID)

	user.Password = ""

	c.JSON(http.StatusOK, user)
}

func GetAllUsers(c *gin.Context) {
	var users []models.User

	result := config.DB.Find(&users)

	if result.Error != nil {
		c.JSON(500, gin.H{"error": "Failed to fetch users"})
		return
	}

	// remove passwords
	for i := range users {
		users[i].Password = ""
	}

	c.JSON(200, users)
}

func CreateUser(c *gin.Context) {
	var user models.User

	// Get data from Flutter
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	// Insert into database
	result := config.DB.Create(&user)

	if result.Error != nil {
		log.Println("ERROR:", result.Error)

		if strings.Contains(result.Error.Error(), "duplicate key") {
			c.JSON(400, gin.H{
				"error": "Email already registered",
			})
			return
		}

		c.JSON(500, gin.H{"error": "Registration failed"})
		return
	}

	log.Println("Insert successful:", result.RowsAffected)

	c.JSON(200, gin.H{
		"message": "User created successfully",
		"data":    user,
	})
}
