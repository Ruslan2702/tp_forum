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
	db.Exec("DELETE FROM votes")
	db.Exec("DELETE FROM posts")
	db.Exec("DELETE FROM threads")
	db.Exec("DELETE FROM forums")
	db.Exec("DELETE FROM users")
}
