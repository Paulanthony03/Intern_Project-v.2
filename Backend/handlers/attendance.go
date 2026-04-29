package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func GetAttendance(c *gin.Context) {
	userID := c.GetUint("user_id")

	rows, err := DB.Query(
		"SELECT id, user_id, date, status, created_at, updated_at FROM attendances WHERE user_id=$1 ORDER BY date DESC",
		userID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch attendance"})
		return
	}
	defer rows.Close()

	var records []gin.H
	for rows.Next() {
		var id uint
		var uid uint
		var date, status string
		var createdAt, updatedAt time.Time

		if err := rows.Scan(&id, &uid, &date, &status, &createdAt, &updatedAt); err != nil {
			continue
		}

		records = append(records, gin.H{
			"id":         id,
			"user_id":    uid,
			"date":       date,
			"status":     status,
			"created_at": createdAt,
			"updated_at": updatedAt,
		})
	}

	c.JSON(http.StatusOK, records)
}

func MarkAttendance(c *gin.Context) {
	userID := c.GetUint("user_id")

	var input struct {
		Date   string `json:"date"`
		Status string `json:"status"` // "present" or "absent"
	}

	if err := c.BindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if input.Status != "present" && input.Status != "absent" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Status must be 'present' or 'absent'"})
		return
	}

	now := time.Now()

	// Upsert: insert or update existing record
	var exists bool
	err := DB.QueryRow(
		"SELECT EXISTS(SELECT 1 FROM attendances WHERE user_id=$1 AND date=$2)",
		userID, input.Date,
	).Scan(&exists)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	if exists {
		_, err = DB.Exec(
			"UPDATE attendances SET status=$1, updated_at=$2 WHERE user_id=$3 AND date=$4",
			input.Status, now, userID, input.Date,
		)
	} else {
		_, err = DB.Exec(
			"INSERT INTO attendances (user_id, date, status, created_at, updated_at) VALUES ($1, $2, $3, $4, $5)",
			userID, input.Date, input.Status, now, now,
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
		"DELETE FROM attendances WHERE user_id=$1 AND date=$2",
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
