package models

import (
	"time"
	"github.com/jackc/pgx"
	"log"
	"fmt"
)

type Post struct {
	Id       int64  `json:"id,omitempty"`
	Parent   int64  `json:"parent,omitempty"`
	Author   string `json:"author,omitempty"`
	Message  string `json:"message,omitempty"`
	IsEdited bool   `json:"isEdited,omitempty"`
	Forum    string `json:"forum,omitempty"`
	Thread   int64  `json:"thread,omitempty"`
	Created  time.Time `json:"created,omitempty"`

	ThreadSlug string `json:"-"`
}

type PostDetails struct {
	MyPost   *Post   `json:"post,omitempty"`
	MyAuthor *User   `json:"author,omitempty"`
	MyThread *Thread `json:"thread,omitempty"`
	MyForum  *Forum  `json:"forum,omitempty"`
}

type PostOnly struct {
	MyPost Post `json:"post,omitempty"`
}

//easyjson:json
type Posts []*Post


func GetPostById(pool *pgx.ConnPool , id string) (*Post, bool) {
	post := Post{}

	query := `
		SELECT id, parent, author, message, isedited, forum, thread, created
		FROM posts
		WHERE posts.id = $1
	`

	err := pool.QueryRow(query, id).Scan(&post.Id, &post.Parent, &post.Author, &post.Message, 
		&post.IsEdited, &post.Forum, &post.Thread, &post.Created)

	if err != nil {
		return nil, false
	}

	return &post, true
}


func CreatePost(pool *pgx.ConnPool , posts []*Post, created string, threadId int64, forum string, user *User) error {
	if len(posts) == 0 {
		return nil
	}

	tx, err := pool.Begin()
	if err != nil {
		log.Print(err)
		return err
	}

	_, err = tx.Prepare("bulk_create", `
		INSERT INTO posts (parent, author, message, isedited, forum, thread, path, created, path_root) 
		VALUES 
				($1::bigint,
				$2,
				$3,
				$4,
				$5,
				$6,
				(SELECT path FROM posts WHERE id = $1) || (select currval('posts_id_seq')::integer),
				$7,
				CASE WHEN $1 = 0
					THEN currval('posts_id_seq')::integer
					ELSE 
						(SELECT path_root FROM posts WHERE id = $1)
				END)
		RETURNING id, created`)

	if err != nil {
		log.Print(err)
		tx.Rollback()
	}

	var post *Post
	for _, post = range posts {
		// if post.Parent != 0 {
		// 	if !CheckParentPost(pool. post.Parent, threadId) {
		// 		tx.Rollback()
		// 		return fmt.Errorf("can't find parent node")
		// 	}
		// }

		err := tx.QueryRow("bulk_create", post.Parent, post.Author, post.Message, post.IsEdited,
			forum, threadId, created).Scan(&post.Id, &post.Created)
		if err != nil {
			log.Print(err)
		}

		post.Thread = threadId
		post.Forum = forum
	}


	queryUpdatePostsCount := `
		UPDATE forums
		SET posts = posts + $1
		WHERE slug = $2
	`
	_, err = tx.Exec(queryUpdatePostsCount, len(posts), post.Forum)
	if err != nil {
		log.Print(err)
	}

	err = tx.Commit()
	if err != nil {
		log.Print(err)
		tx.Rollback()
		return err
	}

	return nil
}


func CheckParentPost(pool *pgx.ConnPool , parent int64, thread int64) bool {
	parentId := 0

	query := `
		SELECT id 
		FROM posts
		WHERE posts.id = $1 AND posts.thread = $2
	`
	err := pool.QueryRow(query, parent, thread).Scan(&parentId)
	if err != nil {
		return false
	}

	return true
}


func UpdatePost(pool *pgx.ConnPool , postId string, newPost Post) string {
	query := `
	UPDATE posts 
	SET message = CASE
		WHEN $1 <> '' THEN $1 
		ELSE message END,

		isedited = true
	WHERE id = $2
`
	_, err := pool.Exec(query, newPost.Message, postId)
	if err != nil {
		return ""
	}

	return newPost.Message
}


func GetPostsList(pool *pgx.ConnPool , threadId string, limit string, since string, sort string, desc string) ([]*Post, error) {
	posts := []*Post{}
	query := `
		SELECT id, parent, author, message, isedited, forum, thread, created 
		FROM posts 
	`
	switch sort {
	case "tree":
		query += ` WHERE thread = $1 `
		eqOp := ""
		if desc == "true" {
			eqOp = " < "
		} else {
			eqOp = " > "
		}

		if since != "" {
			query += fmt.Sprintf(` AND path %s (SELECT path FROM posts WHERE id = %s) `, eqOp, since)
		}

		sortOrd := ""
		sortOrd = ` ASC `
		if desc == "true" {
			sortOrd = ` DESC `
		}

		query += fmt.Sprintf(` ORDER BY path %s `, sortOrd)

		if limit != "" {
			query += fmt.Sprintf(` LIMIT %s `, limit)
		}

		rows, err := pool.Query(query, threadId)
		if err != nil {
			log.Println("tree", err)
			return nil, err
		}
		defer rows.Close()
		
		for rows.Next() {
			post := Post{}
			err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
				&post.IsEdited, &post.Forum, &post.Thread, &post.Created)

			if err != nil {
				log.Println("tree", err)
			}

			posts = append(posts, &post)
		}

	case "parent_tree":
		query += ` WHERE path_root IN ( SELECT id FROM posts WHERE thread = $1 AND parent = 0 `
		eqOp := ""
		if desc == "true" {
			eqOp = " < "
		} else {
			eqOp = " > "
		}

		if since != "" {
			query += fmt.Sprintf(` AND id %s (SELECT path_root FROM posts WHERE id = %s) `, eqOp, since)
		}

		sortOrd := ""
		sortOrd = ` ASC `
		if desc == "true" {
			sortOrd = ` DESC `
		}

		query += fmt.Sprintf(` ORDER BY id %s `, sortOrd)

		if limit != "" {
			query += fmt.Sprintf(` LIMIT %s `, limit)
		}

		query += `)`
		if desc == "true" {
			query += ` ORDER BY path_root DESC, path `
		} else {
			query += ` ORDER BY path`
		}

		rows, err := pool.Query(query, threadId)
		if err != nil {
			log.Println("parent_tree", err)
			return nil, err
		}
		defer rows.Close()

		for rows.Next() {
			post := Post{}
			err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
				&post.IsEdited, &post.Forum, &post.Thread, &post.Created)

			posts = append(posts, &post)
		}
		
	default:
		query += ` WHERE thread = $1 `
		eqOp := ""
		if desc == "true" {
			eqOp = "<"
		} else {
			eqOp = ">"
		}
		if since != "" {
			query += fmt.Sprintf(` AND id %s %s `, eqOp, since)
		}

		sortOrd := ""
		sortOrd = ` ASC `
		if desc == "true" {
			sortOrd = ` DESC `
		}

		query += fmt.Sprintf(` ORDER BY id %s `, sortOrd)

		if limit != "" {
			query += fmt.Sprintf(` LIMIT %s `, limit)
		}

		rows, err := pool.Query(query, threadId)
		if err != nil {
			log.Println("parent_tree", err)
			return nil, err
		}
		defer rows.Close()
		
		for rows.Next() {
			post := Post{}
			err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
				&post.IsEdited, &post.Forum, &post.Thread, &post.Created)

			if err != nil {
				log.Println("parent_tree", err)
			}

			posts = append(posts, &post)
		}
	}
	return posts, nil
}
