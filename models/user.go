package models

import (
	"database/sql"
	_ "encoding/json"
	"fmt"
	"log"
)

type User struct {
	Nickname string `json:"nickname"`
	Fullname string `json:"fullname"`
	About    string `json:"about,omitempty"`
	Email    string `json:"email"`
}

func UpdateUser(db *sql.DB, user *User) error {
	query := `
		UPDATE users 
		SET fullname = CASE
			WHEN $1 <> '' THEN $1 
			ELSE fullname END,

			about = CASE
			WHEN $2 <> '' THEN $2
			ELSE about END,

			email = CASE
			WHEN $3 <> '' THEN $3
			ELSE email END 
		WHERE nickname = $4
		RETURNING fullname, about, email
	`

	err := db.QueryRow(query, user.Fullname, user.About, user.Email, user.Nickname).Scan(
		&user.Fullname, &user.About, &user.Email)


	return err
}

func CreateUser(db *sql.DB, user *User) ([]*User, bool) {
	users := make([]*User, 0)
	usr, got := GetUserByNickname(db, user.Nickname)
	if got {
		users = append(users, usr)
	}

	usr, got = GetUserByEmail(db, user.Email)
	if got && (len(users) == 0 || usr.Nickname != users[0].Nickname) {
		users = append(users, usr)
	}

	if len(users) == 0 {
		query := `
			INSERT INTO users (nickname, fullname, about, email) 
			VALUES 
				($1, $2, $3, $4)
		`

		db.Exec(query, user.Nickname, user.Fullname, user.About, user.Email)
		users = append(users, user)
		return users, true
	} else {
		return users, false
	}
}

func GetUserByNickname(db *sql.DB, nickname string) (*User, bool) {
	usr := User{}

	query := `
		SELECT nickname, fullname, about, email
		FROM users
		WHERE users.nickname = $1
	`

	err := db.QueryRow(query, nickname).Scan(&usr.Nickname, &usr.Fullname, &usr.About, &usr.Email)

	if err != nil {
		return &usr, false
	}

	return &usr, true
}

func GetUserByEmail(db *sql.DB, email string) (*User, bool) {
	usr := User{}

	query := `
		SELECT nickname, fullname, about, email
		FROM users 
		WHERE users.email = $1
	`

	err := db.QueryRow(query, email).Scan(&usr.Nickname, &usr.Fullname, &usr.About, &usr.Email)

	if err != nil {
		return &usr, false
	}

	return &usr, true
}

func GetForumUsers(db *sql.DB, forum string, limit string, since string, desc string) ([]*User, bool) {
	users := make([]*User, 0)

	query := `
		SELECT DISTINCT users.nickname, users.about, users.fullname, users.email 
		FROM users 
		LEFT JOIN posts ON (users.nickname=posts.author) 
		LEFT JOIN threads ON (users.nickname=threads.author) 
		WHERE (threads.forum = $1 OR posts.forum = $1) 
	`

	// query := `
	// 	SELECT nickname, about, fullname, email
	// 	FROM users u 
	// 	WHERE 
	// 		EXISTS (SELECT id FROM posts p WHERE p.author = u.nickname AND p.forum = $1) 
	// 		OR 
	// 		EXISTS (SELECT id FROM threads t WHERE t.author = u.nickname AND t.forum = $1)
	// `


	eqOp := ""
	if desc == "true" {
		eqOp = "<"
	} else {
		eqOp = ">"
	}

	if since != "" {
		query += fmt.Sprintf(" AND nickname %s '%s' ", eqOp, since)
	}
	query += ` ORDER BY nickname `

	if desc == "true" {
		query += `DESC`
	} else {
		query += `ASC`
	}

	if limit != "" {
		query += fmt.Sprintf(` LIMIT %s `, limit)
	}

	rows, err := db.Query(query, forum)
	defer rows.Close()
	fmt.Println("get users: ", err)

	if rows == nil {
		fmt.Print("Parametrs: ", desc, limit, since)
	}

	for rows.Next() {
		user := User{}
		err = rows.Scan(&user.Nickname, &user.About, &user.Fullname, &user.Email)
		if err != nil {
			log.Fatal(err)
		}
		users = append(users, &user)
	}
	err = rows.Close()
	fmt.Println(err)

	return users, true
}
