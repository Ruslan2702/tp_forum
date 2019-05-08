package models

import (
	"github.com/jackc/pgx"
)


func ServiceStatus(pool *pgx.ConnPool ) (int, int, int, int) {
	forums := 0
	threads := 0
	users := 0
	posts := 0

	pool.QueryRow("SELECT COUNT(*) FROM forums").Scan(&forums)
	pool.QueryRow("SELECT COUNT(*) FROM threads").Scan(&threads)
	pool.QueryRow("SELECT COUNT(*) FROM users").Scan(&users)
	pool.QueryRow("SELECT COUNT(*) FROM posts").Scan(&posts)

	return forums, threads, users, posts
}


func DeleteAll(pool *pgx.ConnPool ) {
	_, err := pool.Exec("TRUNCATE votes, posts, threads, forums, users, forum_users RESTART IDENTITY CASCADE")
	_ = err
}
