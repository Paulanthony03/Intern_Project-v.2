package models

type User struct {
	ID       uint   `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email" gorm:"uniqueIndex"`
	Password string `json:"password"`
	InternID string `json:"intern_id"`
	School   string `json:"school"`
}
