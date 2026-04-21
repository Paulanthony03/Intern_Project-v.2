package routes

import (
	"student-system/controllers"
	"student-system/handlers"
	"student-system/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
	public := r.Group("/api")
	{
		public.POST("/register", handlers.Register)
		public.POST("/login", handlers.Login)
		public.GET("/users", handlers.GetAllUsers)

		public.POST("/forgot-password", controllers.ForgotPasswordHandler)
		public.POST("/reset-password", controllers.ResetPasswordHandler)
		public.POST("/verify-otp", controllers.VerifyOTPHandler)
	}

	protected := r.Group("/api")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.GET("/profile", handlers.GetProfile)
		protected.POST("/users", handlers.CreateUser)
		protected.DELETE("/users/:id", handlers.DeleteUser)
	}
}
