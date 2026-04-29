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
	var verified bool

	err = DB.QueryRow(`
	SELECT verified
	FROM email_verifications
	WHERE email=$1
	ORDER BY id DESC
	LIMIT 1
`, user.Email).Scan(&verified)

	if err != nil || !verified {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Email not verified",
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

	now := time.Now()

	_, err = DB.Exec(
		`INSERT INTO users (
			name,
			email,
			password,
			intern_id,
			school,
			program,
			reset_token,
			token_expiry,
			role,
			role_id,
			created_at,
			updated_at,
			department
		)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,

		user.Name,
		user.Email,
		user.Password,
		user.InternID,
		user.School,
		user.Program,
		nil, // reset_token
		nil, // token_expiry
		user.Role,
		1, // role_id (default user role)
		now,
		now,
		user.Department,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
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

func UpdateAdminProfile(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Name       string `json:"name"`
		AdminID    string `json:"admin_id"`
		Email      string `json:"email"`
		PhotoURL   string `json:"photo_url"`
		Department string `json:"department"`
	}

	if err := c.BindJSON(&input); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	_, err := DB.Exec(`
		UPDATE users SET
			name=$1,
			admin_id=$2,
			email=$3,
			photo_url=$4,
			department=$5,
			updated_at=$6
		WHERE id=$7
	`,
		input.Name,
		input.AdminID,
		input.Email,
		input.PhotoURL,
		input.Department,
		time.Now(),
		id,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "Profile updated"})
}

func UploadProfilePhoto(c *gin.Context) {
	file, err := c.FormFile("photo")
	if err != nil {
		c.JSON(400, gin.H{"error": "No file uploaded"})
		return
	}

	filename := time.Now().Format("20060102150405") + "_" + file.Filename
	path := "./uploads/" + filename

	if err := c.SaveUploadedFile(file, path); err != nil {
		c.JSON(500, gin.H{"error": "Failed to save file"})
		return
	}

	c.JSON(200, gin.H{
		"photo_url": "/uploads/" + filename,
	})
}

func UpdatePassword(c *gin.Context) {
	id := c.Param("id")

	var input struct {
		Password string `json:"password"`
	}

	hash, _ := bcrypt.GenerateFromPassword([]byte(input.Password), 14)

	_, err := DB.Exec(
		"UPDATE users SET password=$1 WHERE id=$2",
		string(hash),
		id,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to update password"})
		return
	}

	c.JSON(200, gin.H{"message": "Password updated"})
}
