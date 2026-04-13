package utils

import (
	"github.com/resend/resend-go/v2"
)

func SendEmail(to string, subject string, body string) error {
	client := resend.NewClient("re_FZ5PU9sJ_K4SucRJxNQteVWZovQ6Ukb3S")

	params := &resend.SendEmailRequest{
		From:    "onboarding@resend.dev",
		To:      []string{to},
		Subject: subject,
		Html:    "<p>" + body + "</p>",
	}

	_, err := client.Emails.Send(params)
	return err
}
