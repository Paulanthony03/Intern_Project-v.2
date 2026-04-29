package utils

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

func TestMain() {
	password := "admin123"

	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		fmt.Println("error:", err)
		return
	}

	fmt.Println(string(hash))
}
