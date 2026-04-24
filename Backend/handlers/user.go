package handlers

import (
	"database/sql"
	"net/http"
	"time"

	"student-system/models"

	"github.com/gin-gonic/gin"
)

func GetProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	var user models.User

	err := DB.QueryRow(
		"SELECT id, name, email, password, role FROM users WHERE id=$1",
		userID,
	).Scan(&user.ID, &user.Name, &user.Email, &user.Password, &user.Role)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	if err != nil {
		c.JSON(500, gin.H{"error": "Database error"})
		return
	}

	// remove password
	user.Password = ""

	c.JSON(http.StatusOK, user)
}
func GetUsers(c *gin.Context) {
	rows, err := DB.Query(`
		SELECT id, name, email, password, role, created_at 
		FROM users
		WHERE is_deleted = false
		ORDER BY created_at DESC
	`)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to fetch users"})
		return
	}
	defer rows.Close()

	var users []gin.H

	for rows.Next() {
		var id int
		var name, email, password, role string
		var createdAt time.Time

		err := rows.Scan(&id, &name, &email, &password, &role, &createdAt)
		if err != nil {
			continue
		}

		users = append(users, gin.H{
			"id":         id,
			"name":       name,
			"email":      email,
			"role":       role,
			"created_at": createdAt,
		})
	}

	c.JSON(200, users)
}
func UpdateProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	var input struct {
		Name       string `json:"name"`
		Email      string `json:"email"`
		Contact    string `json:"contact"`
		School     string `json:"school"`
		Department string `json:"department"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	_, err := DB.Exec(
		"UPDATE users SET name=$1, email=$2, contact=$3, school=$4, department=$5 WHERE id=$6",
		input.Name, input.Email, input.Contact, input.School, input.Department, userID,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to update profile: " + err.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "Profile updated successfully"})

}
func CreateUser(c *gin.Context) {
	var user models.User

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	// check if email exists
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
		c.JSON(400, gin.H{"error": "Email already registered"})
		return
	}

	// insert user
	err = DB.QueryRow(
		"INSERT INTO users (name, email, password, role) VALUES ($1, $2, $3, $4) RETURNING id",
		user.Name, user.Email, user.Password, user.Role,
	).Scan(&user.ID)

	if err != nil {
		c.JSON(500, gin.H{"error": "Registration failed"})
		return
	}

	user.Password = ""

	c.JSON(200, gin.H{
		"message": "User created successfully",
		"data":    user,
	})
}
