package config

import (
	"database/sql"
	"student-system/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func ConnectDB() (*sql.DB, error) {
	dsn := "host=localhost user=postgres password=postgres123 dbname=Students port=5432 sslmode=disable"

	gormDB, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	gormDB.AutoMigrate(&models.User{}, &models.OTPCode{})

	sqlDB, err := gormDB.DB()
	if err != nil {
		return nil, err
	}

	return sqlDB, nil
}
