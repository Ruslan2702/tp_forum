package models

import (
	"database/sql"
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
	Created string `json:"created,omitempty"`
}

func GetForumThreads(db *sql.DB, forum string, limit string, since string, desc string) ([]*Thread, bool) {

	threads := make([]*Thread, 0)

	// rows, err := db.Query("")
	// if desc == "true" {
	// 	desc = "DESC"
	// } else {
	// 	desc = ""
	// }

	// if limit != "" {
	// 	if since != "" {
	// 		if desc != "" {
	// 			rows, err = db.Query("SELECT id, title, author, forum, message, votes, slug, created "+
	// 				"FROM threads WHERE threads.forum = $1 AND threads.created <= $2 "+
	// 				"ORDER BY threads.created "+desc+" LIMIT $3", forum, since, limit)
	// 		} else {
	// 			rows, err = db.Query("SELECT id, title, author, forum, message, votes, slug, created "+
	// 				"FROM threads WHERE threads.forum = $1 AND threads.created >= $2 "+
	// 				"ORDER BY threads.created "+desc+" LIMIT $3", forum, since, limit)
	// 		}

	// 	} else {
	// 		rows, err = db.Query("SELECT id, title, author, forum, message, votes, slug, created "+
	// 			"FROM threads WHERE threads.forum = $1 "+
	// 			"ORDER BY threads.created "+desc+" LIMIT $2", forum, limit)

	// 	}
	// } else {
	// 	if since != "" {
	// 		if desc != "" {
	// 			rows, err = db.Query("SELECT id, title, author, forum, message, votes, slug, created "+
	// 				"FROM threads WHERE threads.forum = $1 AND threads.created <= $2 "+
	// 				"ORDER BY threads.created "+desc, forum, since)
	// 		} else {
	// 			rows, err = db.Query("SELECT id, title, author, forum, message, votes, slug, created "+
	// 				"FROM threads WHERE threads.forum = $1 AND threads.created >= $2 "+
	// 				"ORDER BY threads.created "+desc, forum, since)
	// 		}
	// 	} else {
	// 		rows, err = db.Query("SELECT id, title, author, forum, message, votes, slug, created "+
	// 			"FROM threads WHERE threads.forum = $1 "+
	// 			"ORDER BY threads.created "+desc, forum)
	// 	}
	// }

	query := ` SELECT id, title, author, forum, message, votes, slug, created FROM threads WHERE forum = $1 `

	eqOp := ""
	if desc == "true" {
		eqOp = "<="
	} else {
		eqOp = ">="
	}

	if since != "" {
		query += fmt.Sprintf(" AND created %s '%s' ", eqOp, since)
	}
	query += ` ORDER BY created `

	if desc == "true" {
		query += `DESC `
	} else {
		query += `ASC `
	}

	if limit != "" {
		query += fmt.Sprintf(` LIMIT %s `, limit)
	}
	rows, err := db.Query(query, forum)

	if rows == nil {
		fmt.Print("Parametrs: ", desc, limit, since)
	}

	if err != nil {
		fmt.Println(err)
	}

	for rows.Next() {
		thread := Thread{}
		err = rows.Scan(&thread.Id, &thread.Title, &thread.Author, &thread.Forum,
			&thread.Message, &thread.Votes, &thread.Slug, &thread.Created)
		if err != nil {
			log.Fatal(err)
		}
		threads = append(threads, &thread)
	}
	err = rows.Close()
	fmt.Println(err)

	return threads, true
}

func CreateThread(db *sql.DB, thread *Thread) error {
	var err error
	if thread.Created != "" {
		_, err = db.Exec("INSERT INTO threads (author, message, forum, slug, created, title)"+
			" VALUES ($1, $2, $3, $4, $5, $6)", thread.Author, thread.Message, thread.Forum,
			thread.Slug, thread.Created, thread.Title)
		fmt.Println(err)
	} else {
		_, err = db.Exec("INSERT INTO threads (author, message, forum, slug, title)"+
			" VALUES ($1, $2, $3, $4, $5)", thread.Author, thread.Message, thread.Forum,
			thread.Slug, thread.Title)
		fmt.Println(err)
	}

	err = db.QueryRow("SELECT id FROM threads WHERE threads.slug = $1", thread.Slug).Scan(&thread.Id)
	fmt.Println("create_thread_error: ", err)
	_, err = db.Exec("UPDATE forums SET threads = threads + 1 WHERE slug = $1", thread.Forum)
	fmt.Println("create thread: ", err)

	return err
}

func GetThreadByTitle(db *sql.DB, title string) (*Thread, bool) {
	thread := Thread{}

	err := db.QueryRow("SELECT id, title, author, forum, message, votes, slug, created "+
		"FROM threads WHERE threads.title = $1", title).Scan(&thread.Id, &thread.Title,
		&thread.Author, &thread.Forum, &thread.Message, &thread.Votes, &thread.Slug, &thread.Created)

	if err != nil {
		return &thread, false
	}

	return &thread, true
}

func GetThreadBySlug(db *sql.DB, slug string) (*Thread, bool) {
	thread := Thread{}

	err := db.QueryRow("SELECT id, title, author, forum, message, votes, slug, created "+
		"FROM threads WHERE threads.slug = $1", slug).Scan(&thread.Id, &thread.Title,
		&thread.Author, &thread.Forum, &thread.Message, &thread.Votes, &thread.Slug, &thread.Created)

	if err != nil {
		return &thread, false
	}

	return &thread, true
}

func GetThreadById(db *sql.DB, id string) (*Thread, bool) {
	thread := Thread{}

	err := db.QueryRow("SELECT id, title, author, forum, message, votes, slug, created "+
		"FROM threads WHERE threads.id = $1", id).Scan(&thread.Id, &thread.Title,
		&thread.Author, &thread.Forum, &thread.Message, &thread.Votes, &thread.Slug, &thread.Created)

	if err != nil {
		return &thread, false
	}

	return &thread, true
}

func UpdateThread(db *sql.DB, id int64, newThread *Thread, oldThread *Thread) error {
	if newThread.Title != "" {
		db.Exec("UPDATE threads SET title = $1 WHERE id = $2", newThread.Title, id)
	}

	if newThread.Message != "" {
		db.Exec("UPDATE threads SET message = $1 WHERE id = $2", newThread.Message, id)
	}

	err := db.QueryRow("SELECT title, message "+
		"FROM threads WHERE id = $1", id).Scan(&oldThread.Title, &oldThread.Message)

	return err
}
