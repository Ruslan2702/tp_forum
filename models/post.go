package models

import (
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
	err := db.QueryRow("SELECT id, parent, author, message, isedited, forum, thread, created "+
		"FROM posts WHERE posts.id = $1", id).Scan(&post.Id, &post.Parent, &post.Author,
		&post.Message, &post.IsEdited, &post.Forum, &post.Thread, &post.Created)

	if err != nil {
		return nil, false
	}

	return &post, true
}

func CreatePost(db *sql.DB, post *Post, savedCreated string) *Post {
	if savedCreated != "" {
		_, err := db.Exec("INSERT INTO posts (parent, author, message, isedited, forum, thread, created, path)"+
			" VALUES ($1, $2, $3, $4, $5, $6, $7, "+
			"(SELECT path FROM posts WHERE id = $1) || (select currval('posts_id_seq')::integer))",
			post.Parent, post.Author, post.Message, post.IsEdited, post.Forum, post.Thread, savedCreated)
		_ = err
	} else if post.Created != "" {
		_, err := db.Exec("INSERT INTO posts (parent, author, message, isedited, forum, thread, created, path)"+
			" VALUES ($1, $2, $3, $4, $5, $6, $7, "+
			"(SELECT path FROM posts WHERE id = $1) || (select currval('posts_id_seq')::integer))", post.Parent, post.Author, post.Message,
			post.IsEdited, post.Forum, post.Thread, post.Created)
		_ = err
	} else {
		_, err := db.Exec("INSERT INTO posts (parent, author, message, isedited, forum, thread, path)"+
			" VALUES ($1, $2, $3, $4, $5, $6, "+
			"(SELECT path FROM posts WHERE id = $1) || (select currval('posts_id_seq')::integer))", post.Parent, post.Author, post.Message,
			post.IsEdited, post.Forum, post.Thread)
		_ = err
	}

	db.QueryRow("SELECT id FROM posts WHERE posts.message = $1", post.Message).Scan(&post.Id)
	db.QueryRow("SELECT created FROM posts WHERE posts.message = $1", post.Message).Scan(&post.Created)
	_, err := db.Exec("UPDATE forums SET posts = posts + 1 WHERE slug = $1", post.Forum)
	_ = err

	query := ``
	if post.Parent == 0 {
		query += "UPDATE posts SET path_root = $1 WHERE id = $1"
		_, err = db.Exec(query, post.Id)
	} else {
		query += "UPDATE posts SET path_root = (SELECT path_root FROM posts WHERE id = $2) WHERE id = $1"
		_, err = db.Exec(query, post.Id, post.Parent)
	}
	fmt.Println("path_root_update_error ", err)

	return post
}

func CheckParentPost(db *sql.DB, parent int64, thread int64) bool {
	parentId := 0
	err := db.QueryRow("SELECT id "+
		"FROM posts WHERE posts.id = $1 AND posts.thread = $2", parent, thread).Scan(&parentId)

	if err != nil {
		return false
	}

	return true
}

func UpdatePost(db *sql.DB, postId string, newPost Post) string {
	var err error
	if newPost.Message != "" {
		_, err := db.Exec("UPDATE posts SET message = $1, isedited = true WHERE id = $2", newPost.Message, postId)
		_ = err
	}

	// if newPost.Message != "" {
	// 	_, err := db.Exec("UPDATE posts SET message = $1, isedited = true WHERE id = $2", newPost.Message, postId)
	// 	_ = err
	// }

	if err != nil {
		return ""
	}

	return newPost.Message
}

func GetPostsList(db *sql.DB, threadId string, limit string, since string, sort string, desc string) ([]*Post, bool) {
	posts := []*Post{}
	query := `SELECT id, parent, author, message, isedited, forum, thread, created FROM posts `
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
		// if desc != "" {
		// 	sortOrd = ` DESC `
		// } else {
		// 	sortOrd = ` ASC `
		// }
		query += fmt.Sprintf(` ORDER BY path %s `, sortOrd)

		if limit != "" {
			query += fmt.Sprintf(` LIMIT %s `, limit)
		}

		rows, err := db.Query(query, threadId)
		// fmt.Println("tree", err)
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
		// if desc != "" {
		// 	sortOrd = ` DESC `
		// } else {
		// 	sortOrd = ` ASC `
		// }
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
		// if desc == "false" {
		// 	sortOrd = ` ASC `
		// } else {
		// 	sortOrd = ` DESC `
		// }
		query += fmt.Sprintf(` ORDER BY id %s `, sortOrd)

		if limit != "" {
			query += fmt.Sprintf(` LIMIT %s `, limit)
		}

		rows, err := db.Query(query, threadId)
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

// func GetPostsList(db *sql.DB, threadId string, limit string, since string, sort string, desc string) ([]*Post, bool) {
// 	if sort == "tree" {
// 		return treeSorted(db, threadId, limit, since, desc)
// 	} else if sort == "parent_tree" {
// 		return parentTreeSorted(db, threadId, limit)
// 	}

// 	posts := []*Post{}
// 	query := "SELECT id, parent, author, message, isedited, forum, thread, created " +
// 		"FROM posts WHERE thread = $1"

// 	if since != "" {
// 		query += " AND id > " + since
// 	}
// 	query += " ORDER BY (created, id) "
// 	if desc == "true" {
// 		query += " DESC "
// 	}
// 	if limit != "" {
// 		query += " LIMIT " + limit
// 	}
// 	rows, err := db.Query(query, threadId)

// 	// err := db.QueryRow("SELECT id, parent, author, message, isedited, forum, thread, created "+
// 	// 	"FROM posts WHERE posts.id = $1", id).Scan(&post.Id, &post.Parent, &post.Author,
// 	// 	&post.Message, &post.IsEdited, &post.Forum, &post.Thread, &post.Created)

// 	if rows == nil {
// 		fmt.Print("Parametrs: ", desc, limit, since)
// 	}

// 	if err != nil {
// 		fmt.Println(err)
// 	}

// 	for rows.Next() {
// 		post := Post{}
// 		err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
// 			&post.IsEdited, &post.Forum, &post.Thread, &post.Created)
// 		if err != nil {
// 			log.Fatal(err)
// 		}
// 		posts = append(posts, &post)
// 	}

// 	// childs, _ := getChilds(db, posts[0].Id)
// 	// _ = childs

// 	return posts, true
// }

// // func innerGetChilds(db *sql.DB, postId int64) ([]*Post, bool) {

// // }

// func getChilds(db *sql.DB, postId int64) ([]*Post, bool) {
// 	count := 0
// 	posts := []*Post{}
// 	// Базовый случай рекурсии
// 	err := db.QueryRow("SELECT COUNT(*) "+
// 		"FROM posts WHERE path && ARRAY[$1]::integer[]", strconv.FormatInt(postId, 10)).Scan(&count)
// 	if count == 1 {
// 		return posts, false
// 	}
// 	_ = err

// 	rows, err := db.Query("SELECT id, parent, author, message, isedited, forum, thread, created "+
// 		"FROM posts WHERE path && ARRAY[$1]::integer[] ORDER BY (created, id)", strconv.FormatInt(postId, 10))

// 	// err := db.QueryRow("SELECT id, parent, author, message, isedited, forum, thread, created "+
// 	// 	"FROM posts WHERE posts.id = $1", id).Scan(&post.Id, &post.Parent, &post.Author,
// 	// 	&post.Message, &post.IsEdited, &post.Forum, &post.Thread, &post.Created)

// 	if rows == nil {
// 		fmt.Print("Parametrs: ")
// 	}

// 	if err != nil {
// 		fmt.Println(err)
// 	}

// 	i := 0
// 	for rows.Next() {
// 		i++
// 		if i == 1 {
// 			continue
// 		}
// 		post := Post{}
// 		err = rows.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
// 			&post.IsEdited, &post.Forum, &post.Thread, &post.Created)
// 		if err != nil {
// 			log.Fatal(err)
// 		}

// 		childs, _ := getChilds(db, post.Id)
// 		posts = append(posts, childs...)
// 	}

// 	return posts, true
// }

// func treeSorted(db *sql.DB, threadId string, limit string, since string, desc string) ([]*Post, bool) {
// 	posts := []*Post{}
// 	query := "SELECT id, parent, author, message, isedited, forum, thread, created " +
// 		"FROM posts WHERE thread = $1"

// 	if since != "" {
// 		query += " AND id > " + since
// 	}
// 	query += " ORDER BY (created, id) "
// 	if desc == "true" {
// 		query += " DESC "
// 	}
// 	if limit != "" {
// 		query += " LIMIT " + limit
// 	}
// 	roots, err := db.Query(query, threadId)

// 	for roots.Next() {
// 		post := Post{}
// 		err = roots.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
// 			&post.IsEdited, &post.Forum, &post.Thread, &post.Created)
// 		if err != nil {
// 			log.Fatal(err)
// 		}
// 		// posts = append(posts, &post)

// 		childs, _ := getChilds(db, post.Id)
// 		for _, child := range childs {
// 			posts = append(posts, child)
// 		}
// 	}
// 	lim, _ := strconv.Atoi(limit)
// 	if lim <= len(posts) {
// 		return posts[:lim], true
// 	}
// 	return posts, true
// }

// func parentTreeSorted(db *sql.DB, threadId string, limit string) ([]*Post, bool) {
// 	posts := []*Post{}
// 	rootPosts := []*Post{}
// 	roots, err := db.Query("SELECT id, parent, author, message, isedited, forum, thread, created "+
// 		"FROM posts WHERE thread = $1 AND parent = 0 ORDER BY (created, id)", threadId)

// 	for roots.Next() {
// 		post := &Post{}
// 		err = roots.Scan(&post.Id, &post.Parent, &post.Author, &post.Message,
// 			&post.IsEdited, &post.Forum, &post.Thread, &post.Created)
// 		if err != nil {
// 			log.Fatal(err)
// 		}
// 		rootPosts = append(rootPosts, post)
// 	}

// 	lim, _ := strconv.Atoi(limit)
// 	limitedRoots := []*Post{}
// 	if lim < len(rootPosts) {
// 		limitedRoots = rootPosts[:lim]
// 	} else {
// 		limitedRoots = rootPosts
// 	}

// 	for _, root := range limitedRoots {
// 		childs, _ := getChilds(db, root.Id)
// 		for _, child := range childs {
// 			posts = append(posts, child)
// 		}
// 	}

// 	return posts, true
// }
