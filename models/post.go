package models

import (
	"log"
	"database/sql"
	"fmt"
	// "github.com/lib/pq"
)

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

//easyjson:json
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


func CreatePost(db *sql.DB, posts []*Post, created string, threadId int64, forum string) error {
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
	// _ = query

	// INSERT INTO posts (id, parent, author, message, isedited, forum, thread, path, created, path_root)
	// 		(SELECT 
	// 				nextval('posts_id_seq')::integer,
	// 				328928,
	// 				'cadunt.10N28ZDQmcHh7D',
	// 				'msg',
	// 				false,
	// 				'iy0pyI2TIj6iS',
	// 				62916,
	// 				(SELECT path FROM posts WHERE id = 328928) || (select currval('posts_id_seq')::integer),
	// 				now(),
	// 				CASE WHEN 328928 = 0
	// 					THEN currval('posts_id_seq')::integer
	// 					ELSE 
	// 						(SELECT path_root FROM posts WHERE id = 328928)
	// 				END
	// 		)
	// 	RETURNING id, created;
	
	/*
		USED TRIGGER TO UPDATE FIELD forums.posts
		JUST FOR FUN

	CREATE TRIGGER forum_posts_increment
		AFTER INSERT ON threads
		FOR EACH ROW
		EXECUTE PROCEDURE update_posts_count();

	CREATE OR REPLACE FUNCTION update_posts_count() RETURNS TRIGGER AS $example_table$
	BEGIN
		UPDATE forums
		SET posts = posts + 1
		WHERE slug = NEW.forum;
		RETURN NEW;
	END;
	$example_table$ LANGUAGE plpgsql;
	*/


	// err := db.QueryRow(query, post.Parent, post.Author, post.Message, post.IsEdited,
	// 	post.Forum, post.Thread, post.Created).Scan(&post.Id, &post.Created)
	// txn, err := db.Begin()
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// stmt, _ := txn.Prepare(pq.CopyIn("posts", "accountid", "subaccountid")) // MessageDetailRecord is the table name
	// m := &MessageDetailRecord{
	// 	AccountId:          123456,
	// 	SubAccountId:       123434,
	// }
	// mList := make([]*MessageDetailRecord, 0, 100)
	// for i:=0 ; i<100 ; i++ {
	// 	fmt.Println(i)
	// 	mList = append(mList, m)
	// }
	// fmt.Println(m)
	// for _, user := range mList {
	// 	_, err := stmt.Exec(int64(user.AccountId), int64(user.SubAccountId))
	// 	if err != nil {
	// 		log.Fatal(err)
	// 	}
	// }
	// _, err = stmt.Exec()
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// err = stmt.Close()
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// err = txn.Commit()
	// if err != nil {
	// 	log.Fatal(err)
	// }
	if len(posts) == 0 {
		return nil
	}

	// valueStrings := make([]string, 0, len(posts))
	// valueArgs := make([]interface{}, 0, len(posts) * 10)
	
	// for _, post := range posts {
	// 	valueStrings = append(valueStrings, `(nextval('posts_id_seq')::integer,
	// 										  $_,
	// 										  $_,
	// 										  $_,
	// 										  $_,
	// 										  $_,
	// 										  $_,
	// 										  (SELECT path FROM posts WHERE id = $_) || (select currval('posts_id_seq')::integer),
	// 										  $_,
	// 										  CASE WHEN $_ = 0
	// 											THEN currval('posts_id_seq')::integer
	// 											ELSE 
	// 												(SELECT path_root FROM posts WHERE id = $_)
	// 										  END)`)
    //     valueArgs = append(valueArgs, post.Parent)
    //     valueArgs = append(valueArgs, post.Author)
	// 	valueArgs = append(valueArgs, post.Message)
	// 	valueArgs = append(valueArgs, post.IsEdited)
	// 	valueArgs = append(valueArgs, forum)
	// 	valueArgs = append(valueArgs, threadId)
	// 	valueArgs = append(valueArgs, post.Parent)
	// 	valueArgs = append(valueArgs, created)
	// 	valueArgs = append(valueArgs, post.Parent)
	// 	valueArgs = append(valueArgs, post.Parent)
    // }
	
	tx, err := db.Begin()
	for _, post := range posts {
		if post.Parent != 0 {
			if !CheckParentPost(db, post.Parent, threadId) {
				return fmt.Errorf("can't find parent node")
			}
		}

		err := tx.QueryRow(query, post.Parent, post.Author, post.Message, post.IsEdited,
				forum, threadId, created).Scan(&post.Id, &post.Created)

		if err != nil {
			log.Print(err)
			tx.Rollback()
			return err
		}

		tx.Exec(`
			UPDATE forums
			SET posts = posts + 1
			WHERE slug = $1;
		`, forum)

		post.Thread = threadId
		post.Forum = forum
		// post.Created = created
	}
	tx.Commit()

	// err := db.QueryRow(query, post.Parent, post.Author, post.Message, post.IsEdited,
	// 	forum, threadId, created).Scan(&post.Id)

	// stmt := fmt.Sprintf("INSERT INTO posts (id, parent, author, message, isedited, forum, thread, path, created, path_root) VALUES %s", strings.Join(valueStrings, ","))
    // _, err := db.Exec(stmt, valueArgs...)

	if err != nil {
		log.Print(err)
		return err
	}

	return nil
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


func GetPostsList(db *sql.DB, threadId string, limit string, since string, sort string, desc string) ([]*Post, error) {
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
			query += ` ORDER BY path `
		}

		rows, err := db.Query(query, threadId)
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
