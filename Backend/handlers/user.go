package handlers

import (
	"bytes"
	"database/sql"
	"fmt"
	"io"
	"net/http"
	"time"

	"student-system/models"

	"github.com/gin-gonic/gin"
)

func GetProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	var user models.User

	err := DB.QueryRow(
		"SELECT id, name, email, password, role, intern_id, school, contact, department FROM users WHERE id=$1",
		userID,
	).Scan(&user.ID, &user.Name, &user.Email, &user.Password, &user.Role, &user.InternID, &user.School, &user.Contact, &user.Department)

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

	c.JSON(http.StatusOK, gin.H{
		"id":         user.ID,
		"name":       user.Name,
		"email":      user.Email,
		"role":       user.Role,
		"intern_id":  user.InternID,
		"school":     user.School,
		"contact":    user.Contact,
		"department": user.Department,
	})
}
func GetUsers(c *gin.Context) {
	rows, err := DB.Query(`
		SELECT id, name, email, password, role, created_at, intern_id, school, contact, department
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
		var name, email, password, role, internID, school, contact, department string
		var createdAt time.Time

		err := rows.Scan(&id, &name, &email, &password, &role, &createdAt, &internID, &school, &contact, &department)
		if err != nil {
			continue
		}

		users = append(users, gin.H{
			"id":         id,
			"name":       name,
			"email":      email,
			"role":       role,
			"created_at": createdAt,
			"intern_id":  internID,
			"school":     school,
			"contact":    contact,
			"department": department,
		})
	}

	c.JSON(200, users)
}
func UpdateProfile(c *gin.Context) {
	userID := c.GetUint("user_id")

	fmt.Println("=== UpdateProfile called, userID:", userID)

	body, _ := io.ReadAll(c.Request.Body)
	fmt.Println("=== Raw body:", string(body))
	c.Request.Body = io.NopCloser(bytes.NewBuffer(body))

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

	fmt.Println("=== Input received:", input)

	result, err := DB.Exec(
		"UPDATE users SET name=$1, email=$2, contact=$3, school=$4, department=$5 WHERE id=$6",
		input.Name, input.Email, input.Contact, input.School, input.Department, userID,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to update profile: " + err.Error()})
		return
	}
	rowsAffected, _ := result.RowsAffected()
	fmt.Println("=== Rows affected:", rowsAffected)

	if rowsAffected == 0 {
		c.JSON(404, gin.H{"error": "No user found with that ID"})
		return
	}

	// Fetch updated user to return in response
	var user models.User
	err = DB.QueryRow(
		"SELECT id, name, email, role, intern_id, school, contact, department FROM users WHERE id=$1",
		userID,
	).Scan(&user.ID, &user.Name, &user.Email, &user.Role, &user.InternID, &user.School, &user.Contact, &user.Department)

	if err != nil {
		c.JSON(500, gin.H{"error": "Profile updated but failed to fetch updated data"})
		return
	}

	c.JSON(200, gin.H{
		"id":         user.ID,
		"name":       user.Name,
		"email":      user.Email,
		"role":       user.Role,
		"intern_id":  user.InternID,
		"school":     user.School,
		"contact":    user.Contact,
		"department": user.Department,
	})
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
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	user.Password = ""

	c.JSON(200, gin.H{
		"message": "User created successfully",
		"data":    user,
	})
}
func UploadPhoto(c *gin.Context) {
	userID := c.GetUint("user_id")

	file, err := c.FormFile("photo")
	if err != nil {
		c.JSON(400, gin.H{"error": "No file uploaded"})
		return
	}

	filename := fmt.Sprintf("uploads/%d_%s", userID, file.Filename)
	if err := c.SaveUploadedFile(file, filename); err != nil {
		c.JSON(500, gin.H{"error": "Failed to save file"})
		return
	}

	photoUrl := "/" + filename
	_, err = DB.Exec("UPDATE users SET photo_url=$1 WHERE id=$2", photoUrl, userID)
	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to update photo"})
		return
	}

	c.JSON(200, gin.H{"photo_url": photoUrl})
}
