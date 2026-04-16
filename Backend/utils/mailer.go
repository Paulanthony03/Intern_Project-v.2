package utils

import (
	"net/smtp"
)

func SendOTPEmail(to string, otp string) error {
	from := "cpe.manguiat.paulanthony@gmail.com"
	password := "your_app_password"

	msg := []byte("Subject: OTP Code\n\nYour OTP is: " + otp)

	auth := smtp.PlainAuth("", from, password, "smtp.gmail.com")

	return smtp.SendMail(
		"smtp.gmail.com:587",
		auth,
		from,
		[]string{to},
		msg,
	)
}
