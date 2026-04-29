package models

type Department struct {
	ID             int    `json:"id"`
	DepartmentName string `json:"department_name"`
	SupervisorName string `json:"supervisor_name"`
	SupervisorID   string `json:"supervisor_id"`
	Role           string `json:"role"`
	StartDate      string `json:"start_date"`
	EndDate        string `json:"end_date"`
	Status         string `json:"status"`
}
