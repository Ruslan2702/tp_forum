package models

import (
	"log"
	"database/sql"
	"fmt"
)

//easyjson:json
type Post struct {
	Id       int64  `json:"id,omitempty"`
	Parent   int64  `json:"parent,omitempty"`
	Author   string `json:"author,omitempty"`
	Message  string `json:"message,omitempty"`
	IsEdited bool   `json:"isEdited,omitempty"`
	Forum    string `json:"forum,omitempty"`
	Thread   int64  `json:"thread,omitempty"`
	Created  string `json:"created,omitempty"`

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

//type PostList []*Post

// //easyjson:json

type Posts []*Post

func GetPostById(db *sql.DB, id string) (*Post, bool) {
	post := Post{}

	query := `
		SELECT id, parent, author, message, isedited, forum, thread, created
		FROM posts
		WHERE posts.id = $1
	`

	err := db.QueryRow(query, id).Scan(&post.Id, &post.Parent, &post.Author, &post.Message, 
		&post.IsEdited, &post.Forum, &post.Thread, &post.Created)

	if err != nil {
		return nil, false
	}

	return &post, true
}

func CreatePost(db *sql.DB, post *Post) (string, error) {
	// if savedCreated != "" {
	// 	_, err := db.Exec("INSERT INTO posts (parent, author, message, isedited, forum, thread, created, path)"+
	// 		" VALUES ($1, $2, $3, $4, $5, $6, $7, "+
	// 		"(SELECT path FROM posts WHERE id = $1) || (select currval('posts_id_seq')::integer))",
	// 		post.Parent, post.Author, post.Message, post.IsEdited, post.Forum, post.Thread, savedCreated)
	// 	_ = err
	// } else if post.Created != "" {
	// 	_, err := db.Exec("INSERT INTO posts (parent, author, message, isedited, forum, thread, created, path)"+
	// 		" VALUES ($1, $2, $3, $4, $5, $6, $7, "+
	// 		"(SELECT path FROM posts WHERE id = $1) || (select currval('posts_id_seq')::integer))", post.Parent, post.Author, post.Message,
	// 		post.IsEdited, post.Forum, post.Thread, post.Created)
	// 	_ = err
	// } else {
	// 	_, err := db.Exec("INSERT INTO posts (parent, author, message, isedited, forum, thread, path)"+
	// 		" VALUES ($1, $2, $3, $4, $5, $6, "+
	// 		"(SELECT path FROM posts WHERE id = $1) || (select currval('posts_id_seq')::integer))", post.Parent, post.Author, post.Message,
	// 		post.IsEdited, post.Forum, post.Thread)
	// 	_ = err
	// }

	// db.QueryRow("SELECT id FROM posts WHERE posts.message = $1", post.Message).Scan(&post.Id)
	// db.QueryRow("SELECT created FROM posts WHERE posts.message = $1", post.Message).Scan(&post.Created)
	// _, err := db.Exec("UPDATE forums SET posts = posts + 1 WHERE slug = $1", post.Forum)
	// _ = err

	query := `
		INSERT INTO posts (id, parent, author, message, isedited, forum, thread, path, created, path_root)
			(SELECT 
					nextval('posts_id_seq')::integer,
					$1,
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
					END
			)
		RETURNING id, created;
	`

	// INSERT INTO posts (parent, author, message, isedited, forum, thread, path, created, path_root)
	// 	(SELECT 235636,
	// 			'sim.bvMm5Z6og9Z6pv',
	// 			'msg',
	// 			false,
	// 			'Nt_kymMn8j66R',
	// 			48335,
	// 			(SELECT path FROM posts WHERE id = 235636),
	// 			now(),
	// 			CASE WHEN 0 = 0
	// 				THEN 0
	// 				ELSE 
	// 					(SELECT path_root FROM posts WHERE id = 235636)
	// 			END
	// 	)
	// 	RETURNING id;

	// queryUpdate := `
	// 	UPDATE forums 
	// 	SET posts = posts + 1
	// 	WHERE slug = $1
	// 	RETURNING id
	// `

	// tx, err := db.Begin()
	// for _, post := range posts {
	// if _, has := GetUserByNickname(db, post.Author); !has {
	// 	return post.Author, fmt.Errorf("Author")
	// }

	// if post.Created == "" {
	// 	post.Created = created
	// }

	err := db.QueryRow(query, post.Parent, post.Author, post.Message, post.IsEdited,
		post.Forum, post.Thread, post.Created).Scan(&post.Id, &post.Created)

	if err != nil {
		log.Print(err)
		return "", err
	}

	//  test := 0
	// err = db.QueryRow(queryUpdate, post.Forum).Scan(&test)
	// if err != nil {
	// 	log.Print(err)
	// }
		// post.Thread = threadId
		// post.Forum = forum


		// res := db.QueryRow(queryUpdate, post.Id, post.Parent)
		// fmt.Println(res)
	// }
	// tx.Commit()


	// query = ``
	// if post.Parent == 0 {
	// 	query += "UPDATE posts SET path_root = $1 WHERE id = $1"
	// 	_, err = db.Exec(query, post.Id)
	// } else {
	// 	query += "UPDATE posts SET path_root = (SELECT path_root FROM posts WHERE id = $2) WHERE id = $1"
	// 	_, err = db.Exec(query, post.Id, post.Parent)
	// }
	// fmt.Println("path_root_update_error ", err)

	return "", nil
}

func CheckParentPost(db *sql.DB, parent int64, thread int64) bool {
	parentId := 0

	query := `
		SELECT id 
		FROM posts
		WHERE posts.id = $1 AND posts.thread = $2
	`

	err := db.QueryRow(query, parent, thread).Scan(&parentId)

	if err != nil {
		return false
	}

	return true
}

func UpdatePost(db *sql.DB, postId string, newPost Post) string {
	query := `
	UPDATE posts 
	SET message = CASE
		WHEN $1 <> '' THEN $1 
		ELSE message END,

		isedited = true
	WHERE id = $2
`
	_, err := db.Exec(query, newPost.Message, postId)

	if err != nil {
		return ""
	}

	return newPost.Message
}

func GetPostsList(db *sql.DB, threadId string, limit string, since string, sort string, desc string) ([]*Post, bool) {
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

		rows, err := db.Query(query, threadId)
		// fmt.Println("tree", err)
		defer rows.Close()
		for rows.Next() {
			post := Post{}
			if err != nil {
				fmt.Println("tree", err)
			}
			err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
				&post.IsEdited, &post.Forum, &post.Thread, &post.Created)
			// fmt.Println("tree", err)
			posts = append(posts, &post)
		}

	case "parent_tree":
		/*
		SELECT id, parent, author, message, isedited, forum, thread, created 
		FROM posts WHERE path_root IN ( SELECT id FROM posts WHERE thread = 'olURg1n2vJO-K' AND parent = 0
										ORDER BY id LIMIT 65)
		ORDER BY path
		*/

		query += ` WHERE path_root IN ( SELECT id FROM posts WHERE thread = $1 AND parent = 0 `
		// 31846
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
			query += ` ORDER BY path `
		}

		rows, err := db.Query(query, threadId)
		defer rows.Close()
		// fmt.Println("parent_tree", err)
		for rows.Next() {
			post := Post{}
			if err != nil {
				fmt.Println("parent_tree", err)
			}
			err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
				&post.IsEdited, &post.Forum, &post.Thread, &post.Created)
			// fmt.Println("parent_tree", err)
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

		rows, err := db.Query(query, threadId)
		defer rows.Close()
		// fmt.Println("flat", err)
		for rows.Next() {
			post := Post{}
			if err != nil {
				fmt.Println("flat", err)
			}
			err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
				&post.IsEdited, &post.Forum, &post.Thread, &post.Created)
			// fmt.Println(err)
			posts = append(posts, &post)
		}
	}
	return posts, true
}
