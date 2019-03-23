package models

import (
	"database/sql"
)

type Forum struct {
	Title string `json:"title"`
	User string `json:"user"`
	Slug string	`json:"slug"`
	Posts int64 `json:"posts,omitempty"`
	Threads int32 `json:"threads,omitempty"`
}

func CreateForum(db *sql.DB, forum *Forum) bool {
	_, err := db.Exec("INSERT INTO forums (title, user_nickname, slug, posts, threads) " +
		"VALUES ($1, $2, $3, $4, $5)", forum.Title, forum.User, forum.Slug, forum.Posts, forum.Threads)
	_ = err
	return true
}

func GetForumBySlug(db *sql.DB, slug string) (*Forum, bool) {
	forum := Forum{}

	err := db.QueryRow("SELECT title, user_nickname, slug, posts, threads " +
		"FROM forums WHERE forums.slug = $1", slug).Scan(&forum.Title, &forum.User,
		&forum.Slug, &forum.Posts, &forum.Threads)

	if err != nil {
		return &forum, false
	}

	return &forum, true
}