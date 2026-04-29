package controllers

import (
	"student-system/models"

	"github.com/gin-gonic/gin"
)

func CreateDepartment(c *gin.Context) {
	var dept models.Department

	if err := c.ShouldBindJSON(&dept); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	dept.Role = "Supervisor"

	_, err := db.Exec(`
		INSERT INTO departments 
		(department_name, supervisor_name, role, supervisor_id, start_date, end_date)
		VALUES ($1,$2,$3,$4,$5,$6)
	`,
		dept.DepartmentName,
		dept.SupervisorName,
		dept.Role,
		dept.SupervisorID,
		dept.StartDate,
		dept.EndDate,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "Department created"})
}
func GetDepartments(c *gin.Context) {
	rows, err := db.Query(`SELECT id, department_name, supervisor_name, role, supervisor_id, start_date, end_date FROM departments`)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var departments []models.Department

	for rows.Next() {
		var d models.Department
		rows.Scan(&d.ID, &d.DepartmentName, &d.SupervisorName, &d.Role, &d.SupervisorID, &d.StartDate, &d.EndDate)
		departments = append(departments, d)
	}

	c.JSON(200, departments)
}
func UpdateDepartment(c *gin.Context) {
	id := c.Param("id")
	var dept models.Department

	if err := c.ShouldBindJSON(&dept); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	_, err := db.Exec(`
		UPDATE departments 
		SET department_name=$1, supervisor_name=$2, supervisor_id=$3, start_date=$4, end_date=$5
		WHERE id=$6
	`,
		dept.DepartmentName,
		dept.SupervisorName,
		dept.SupervisorID,
		dept.StartDate,
		dept.EndDate,
		id,
	)

	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "Updated successfully"})
}
func DeleteDepartment(c *gin.Context) {
	id := c.Param("id")

	_, err := db.Exec(`DELETE FROM departments WHERE id=$1`, id)
	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "Deleted successfully"})
}
