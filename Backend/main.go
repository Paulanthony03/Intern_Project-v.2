package main

import (
	"log"
	config "student-system/config"
	"student-system/controllers"
	"student-system/handlers"
	"student-system/routes"
	"student-system/utils"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {

	utils.TestMain()

	db, err := config.ConnectDB()
	if err != nil {
		panic(err)
	}

	handlers.SetDB(db)

	controllers.SetDB(db)

	r := gin.Default()

	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
	}))

	r.OPTIONS("/*path", func(c *gin.Context) {
		c.AbortWithStatus(204)
	})

	routes.SetupRoutes(r)

	r.Static("/uploads", "./uploads")

	log.Println("Server is starting on port :8080...")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

}
