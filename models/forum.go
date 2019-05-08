package models

import (
	// "database/sql"
	"github.com/jackc/pgx"
)

type Forum struct {
	Title string `json:"title"`
	User string `json:"user"`
	Slug string	`json:"slug"`
	Posts int64 `json:"posts,omitempty"`
	Threads int32 `json:"threads,omitempty"`
}


func CreateForum(pool *pgx.ConnPool , forum *Forum) bool {
	query := `
		INSERT INTO forums (title, user_nickname, slug, posts, threads)
		VALUES 
			($1, $2, $3, $4, $5)
	`

	_, err := pool.Exec(query, forum.Title, forum.User, forum.Slug, forum.Posts, forum.Threads)
	_ = err
	return true
}


func GetForumBySlug(pool *pgx.ConnPool , slug string) (*Forum, bool) {
	forum := Forum{}

	query := `
		SELECT title, user_nickname, slug, posts, threads
		FROM forums
		WHERE forums.slug = $1
	`

	err := pool.QueryRow(query, slug).Scan(&forum.Title, &forum.User, &forum.Slug, &forum.Posts, &forum.Threads)

	if err != nil {
		return &forum, false
	}

	return &forum, true
}