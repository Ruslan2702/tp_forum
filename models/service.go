package models

import (
	// "github.com/jackc/pgx"
)

import "database/sql"


func ServiceStatus(db *sql.DB) (int, int, int, int) {
	forums := 0
	threads := 0
	users := 0
	posts := 0

	db.QueryRow("SELECT COUNT(*) FROM forums").Scan(&forums)
	db.QueryRow("SELECT COUNT(*) FROM threads").Scan(&threads)
	db.QueryRow("SELECT COUNT(*) FROM users").Scan(&users)
	db.QueryRow("SELECT COUNT(*) FROM posts").Scan(&posts)

	return forums, threads, users, posts
}


func DeleteAll(db *sql.DB) {
	_, err := db.Exec("TRUNCATE votes, posts, threads, forums, users RESTART IDENTITY CASCADE")
	// _, err := db.Exec("TRUNCATE TABLE votes CASCADE")
	// _, err = db.Exec("TRUNCATE TABLE posts CASCADE")
	// _, err = db.Exec("TRUNCATE TABLE threads CASCADE")
	// _, err = db.Exec("TRUNCATE TABLE forums CASCADE")
	// _, err = db.Exec("TRUNCATE TABLE users CASCADE")
	_ = err
}
