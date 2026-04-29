package config

import (
	"database/sql"
	"log"
	"student-system/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func ConnectDB() (*sql.DB, error) {
	dsn := "host=localhost user=postgres password=postgres dbname=intern5-romabay port=5432 sslmode=disable"

	gormDB, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Printf("❌ DB Connection failed: %v", err)
		return nil, err
	}

	// Auto-migrate tables
	if err := gormDB.AutoMigrate(&models.User{}, &models.OTPCode{}); err != nil {
		log.Printf("❌ AutoMigrate failed: %v", err)
		return nil, err
	}

	sqlDB, err := gormDB.DB()
	if err != nil {
		return nil, err
	}

	// Test ping
	if err := sqlDB.Ping(); err != nil {
		log.Printf("❌ DB Ping failed: %v", err)
		return nil, err
	}

	log.Println("✅ Database connected to 'intern5-romabay' and tables ready!")
	return sqlDB, nil
}
