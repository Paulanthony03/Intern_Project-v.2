package handlers

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetAttendance(c *gin.Context) {
	userID := c.GetUint("user_id")

	rows, err := DB.Query(
		"SELECT date, status FROM attendance WHERE user_id=$1",
		userID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch attendance"})
		return
	}
	defer rows.Close()

	attendance := map[string]string{}
	for rows.Next() {
		var date, status string
		if err := rows.Scan(&date, &status); err != nil {
			continue
		}
		attendance[date] = status
	}

	c.JSON(http.StatusOK, attendance)
}

func MarkAttendance(c *gin.Context) {
	userID := c.GetUint("user_id")
	fmt.Println("=== MARK ATTENDANCE called, userID:", userID)

	var input struct {
		Date   string `json:"date"`
		Status string `json:"status"`
	}

	if err := c.BindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Empty status = toggle off = delete
	if input.Status == "" {
		_, err := DB.Exec(
			"DELETE FROM attendance WHERE user_id=$1 AND date=$2",
			userID, input.Date,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete attendance"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"message": "Attendance removed"})
		return
	}

	var exists bool
	err := DB.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM attendance WHERE user_id=$1 AND date=$2)",
		userID, input.Date,
	).Scan(&exists)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	if exists {
		_, err = DB.Exec(
			"UPDATE attendance SET status=$1 WHERE user_id=$2 AND date=$3",
			input.Status, userID, input.Date,
		)
	} else {
		// Remove created_at and updated_at from insert
		_, err = DB.Exec(
			"INSERT INTO attendance (user_id, date, status) VALUES ($1, $2, $3)",
			userID, input.Date, input.Status,
		)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save attendance"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Attendance recorded",
		"date":    input.Date,
		"status":  input.Status,
	})
}

func DeleteAttendance(c *gin.Context) {
	userID := c.GetUint("user_id")
	date := c.Param("date")

	result, err := DB.Exec(
		"DELETE FROM attendance WHERE user_id=$1 AND date=$2",
		userID, date,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete attendance"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Attendance record not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Attendance record removed"})
}
