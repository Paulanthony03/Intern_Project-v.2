package routes

import (
	"student-system/handlers"
	"student-system/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
	r.POST("/api/register", handlers.Register)
	r.POST("/api/login", handlers.Login)
	r.GET("/api/users", handlers.GetAllUsers)

	auth := r.Group("/api")
	auth.Use(middleware.AuthMiddleware())
	{
		auth.GET("/profile", handlers.GetProfile)
		auth.POST("/users", handlers.CreateUser)
	}
}
