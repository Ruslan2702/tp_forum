package models

import (
	"time"
	"github.com/jackc/pgx"
	"fmt"
	"log"
)

type Thread struct {
	Id      int64  `json:"id,omitempty"`
	Title   string `json:"title"`
	Author  string `json:"author"`
	Forum   string `json:"forum"`
	Message string `json:"message,omitempty"`
	Votes   int32  `json:"votes,omitempty"`
	Slug    string `json:"slug,omitempty"`
	Created time.Time `json:"created,omitempty"`
}


func GetForumThreads(pool *pgx.ConnPool , forum string, limit string, since string, desc string) ([]*Thread, bool) {
	threads := make([]*Thread, 0)

	query := `
		SELECT id, title, author, forum, message, votes, slug, created 
		FROM threads 
		WHERE forum = $1 
	`

	eqOp := ""
	if desc == "true" {
		eqOp = "<="
	} else {
		eqOp = ">="
	}

	if since != "" {
		query += fmt.Sprintf(" AND created %s '%s' ", eqOp, since)
	}
	query += " ORDER BY created "

	if desc == "true" {
		query += " DESC "
	} else {
		query += " ASC "
	}

	if limit != "" {
		query += fmt.Sprintf(" LIMIT %s ", limit)
	}

	rows, err := pool.Query(query, forum)
	defer rows.Close()

	for rows.Next() {
		thread := Thread{}
		err = rows.Scan(&thread.Id, &thread.Title, &thread.Author, &thread.Forum,
			&thread.Message, &thread.Votes, &thread.Slug, &thread.Created)
		if err != nil {
			log.Fatal(err)
		}
		threads = append(threads, &thread)
	}
	rows.Close()

	return threads, true
}


func CreateThread(pool *pgx.ConnPool , thread *Thread) error {
	var err error

	query := `
		INSERT INTO threads (author, message, forum, slug, title, created)
		(SELECT $1,
				$2,
				$3,
				$4,
				$5,
				$6
		)
		RETURNING id;
	`

	err = pool.QueryRow(query, thread.Author, thread.Message, thread.Forum, 
		thread.Slug, thread.Title, thread.Created).Scan(&thread.Id)

	/*
		USED TRIGGER TO UPDATE FIELD forums.threads
		JUST FOR FUN

	CREATE TRIGGER forum_threads_increment
		AFTER INSERT ON threads
		FOR EACH ROW
		EXECUTE PROCEDURE update_threads_count();

	CREATE OR REPLACE FUNCTION update_threads_count() RETURNS TRIGGER AS $example_table$
	BEGIN
		UPDATE forums
		SET threads = threads + 1
		WHERE slug = NEW.forum;
		RETURN NEW;
	END;
	$example_table$ LANGUAGE plpgsql;
	*/

	return err
}


func GetThreadBySlug(pool *pgx.ConnPool , slug string) (*Thread, bool) {
	thread := Thread{}

	query := `
		SELECT id, title, author, forum, message, votes, slug, created
		FROM threads
		WHERE threads.slug = $1
	`

	err := pool.QueryRow(query, slug).Scan(&thread.Id, &thread.Title,
		&thread.Author, &thread.Forum, &thread.Message, &thread.Votes, &thread.Slug, &thread.Created)

	if err != nil {
		return &thread, false
	}

	return &thread, true
}


func GetThreadById(pool *pgx.ConnPool , id string) (*Thread, bool) {
	thread := Thread{}

	query := `
		SELECT id, title, author, forum, message, votes, slug, created
		FROM threads
		WHERE threads.id = $1
	`

	err := pool.QueryRow(query, id).Scan(&thread.Id, &thread.Title,
		&thread.Author, &thread.Forum, &thread.Message, &thread.Votes, &thread.Slug, &thread.Created)

	if err != nil {
		return &thread, false
	}

	return &thread, true
}


func UpdateThread(pool *pgx.ConnPool , id int64, newThread *Thread, oldThread *Thread) error {
	query := `
		UPDATE threads 
		SET title = CASE
			WHEN $1 <> '' THEN $1 
			ELSE title END,

			message = CASE
			WHEN $2 <> '' THEN $2
			ELSE message END
		WHERE id = $3
		RETURNING Title, Message
	`
	err := pool.QueryRow(query, newThread.Title, newThread.Message, id).Scan(&oldThread.Title, &oldThread.Message)

	return err
}
