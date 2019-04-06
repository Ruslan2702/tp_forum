package models

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
	db.Exec("TRUNCATE TABLE votes CASCADE")
	db.Exec("TRUNCATE TABLE posts CASCADE")
	db.Exec("TRUNCATE TABLE threads CASCADE")
	db.Exec("TRUNCATE TABLE forums CASCADE")
	db.Exec("TRUNCATE TABLE users CASCADE")
	
}
