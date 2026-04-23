package handlers

import (
	"database/sql"
	"net/http"
	"time"

	"student-system/models"
	"student-system/utils"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

var DB *sql.DB

func SetDB(database *sql.DB) {
	DB = database
}
func Register(c *gin.Context) {
	var user models.User

	if err := c.BindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var exists bool
	err := DB.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)",
		user.Email,
	).Scan(&exists)

	if err != nil {
		c.JSON(500, gin.H{"error": "Database error"})
		return
	}

	if exists {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Email already exists",
		})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(user.Password), 14)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to hash password"})
		return
	}

	user.Password = string(hash)
	user.Role = "user"

	_, err = DB.Exec(
		"INSERT INTO users (name, email, password, role, created_at) VALUES ($1, $2, $3, $4, $5)",
		user.Name,
		user.Email,
		user.Password,
		user.Role,
		time.Now(),
	)

	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to register user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User registered"})
}
func Login(c *gin.Context) {
	var input models.User
	var user models.User

	if err := c.BindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// fetch user
	err := DB.QueryRow(
		"SELECT id, name, email, password, role FROM users WHERE email=$1",
		input.Email,
	).Scan(&user.ID, &user.Name, &user.Email, &user.Password, &user.Role)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	if err != nil {
		c.JSON(500, gin.H{"error": "Database error"})
		return
	}

	// compare password
	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Wrong password"})
		return
	}

	token, err := utils.GenerateToken(user.ID)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to generate token"})
		return
	}

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
func DeleteUser(c *gin.Context) {
	id := c.Param("id")

	// check if user exists
	var exists bool
	err := DB.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM users WHERE id=$1)",
		id,
	).Scan(&exists)

	if err != nil {
		c.JSON(500, gin.H{"error": "Database error"})
		return
	}

	if !exists {
		c.JSON(404, gin.H{"error": "User not found"})
		return
	}

	// delete user
	_, err = DB.Exec("DELETE FROM users WHERE id=$1", id)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to delete user"})
		return
	}

	c.JSON(200, gin.H{"message": "User deleted successfully"})
}
