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

type ByNick []*User

func (a ByNick) Len() int           { return len(a) }
func (a ByNick) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a ByNick) Less(i, j int) bool { return a[i].Nickname < a[j].Nickname }

func UpdateUser(db *sql.DB, user *User) error {
	db.Exec("UPDATE users SET fullname = $2"+
		" WHERE nickname = $1", user.Nickname, user.Fullname)

	db.Exec("UPDATE users SET about = $2"+
		" WHERE nickname = $1", user.Nickname, user.About)

	db.Exec("UPDATE users SET email = $2"+
		" WHERE nickname = $1", user.Nickname, user.Email)

	err := db.QueryRow("SELECT fullname, about, email "+
		"FROM users WHERE users.nickname = $1", user.Nickname).Scan(&user.Fullname,
		&user.About, &user.Email)

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
		db.Exec("INSERT INTO users (nickname, fullname, about, email)"+
			" VALUES ($1, $2, $3, $4)", user.Nickname, user.Fullname, user.About, user.Email)
		users = append(users, user)
		return users, true
	} else {
		return users, false
	}
}

func GetUserByNickname(db *sql.DB, nickname string) (*User, bool) {
	usr := User{}

	err := db.QueryRow("SELECT nickname, fullname, about, email "+
		"FROM users WHERE users.nickname = $1", nickname).Scan(&usr.Nickname, &usr.Fullname,
		&usr.About, &usr.Email)

	if err != nil {
		return &usr, false
	}

	return &usr, true
}

func GetUserByEmail(db *sql.DB, email string) (*User, bool) {
	usr := User{}

	err := db.QueryRow("SELECT nickname, fullname, about, email "+
		"FROM users WHERE users.email = $1", email).Scan(&usr.Nickname, &usr.Fullname,
		&usr.About, &usr.Email)

	if err != nil {
		return &usr, false
	}

	return &usr, true
}

func GetForumUsers(db *sql.DB, forum string, limit string, since string, desc string) ([]*User, bool) {

	users := make([]*User, 0)

	// comparator := ""
	// if desc == "false" || desc == "" {
	// 	comparator = ">"
	// } else {
	// 	comparator = "<"
	// }

	// rows, err := db.Query("")
	// if desc == "true" {
	// 	desc = "DESC"
	// } else {
	// 	desc = ""
	// }

	// if limit != "" {
	// 	if since != "" {
	// 		rows, err = db.Query("SELECT DISTINCT users.nickname, users.about, users.fullname, users.email FROM "+
	// 			"users LEFT JOIN posts ON (users.nickname=posts.author) "+
	// 			"LEFT JOIN threads ON (users.nickname=threads.author) WHERE (threads.forum = $1 OR "+
	// 			"posts.forum = $1) AND users.nickname "+comparator+" $2 ORDER BY users.nickname "+desc+" LIMIT $3", forum, since, limit)
	// 	} else {
	// 		rows, err = db.Query("SELECT DISTINCT users.nickname, users.about, users.fullname, users.email FROM "+
	// 			"users LEFT JOIN posts ON (users.nickname=posts.author) "+
	// 			"LEFT JOIN threads ON (users.nickname=threads.author) WHERE (threads.forum = $1 OR "+
	// 			"posts.forum = $1) ORDER BY users.nickname "+desc+" LIMIT $2", forum, limit)
	// 	}

	// } else {
	// 	if since != "" {
	// 		rows, err = db.Query("SELECT DISTINCT users.nickname, users.about, users.fullname, users.email FROM "+
	// 			"users LEFT JOIN posts ON (users.nickname=posts.author) "+
	// 			"LEFT JOIN threads ON (users.nickname=threads.author) WHERE (threads.forum = $1 OR "+
	// 			"posts.forum = $1) AND users.nickname < $2 ORDER BY users.nickname "+desc, forum, since)
	// 	} else {
	// 		rows, err = db.Query("SELECT DISTINCT users.nickname, users.about, users.fullname, users.email FROM "+
	// 			"users LEFT JOIN posts ON (users.nickname=posts.author) "+
	// 			"LEFT JOIN threads ON (users.nickname=threads.author) WHERE (threads.forum = $1 OR "+
	// 			"posts.forum = $1) ORDER BY users.nickname "+desc, forum)
	// 	}

	// }
	query := fmt.Sprintf(` SELECT DISTINCT users.nickname, users.about, users.fullname, users.email FROM 
		users LEFT JOIN posts ON (users.nickname=posts.author) 
		LEFT JOIN threads ON (users.nickname=threads.author) WHERE (threads.forum = '%s' OR 
		posts.forum = '%s') `, forum, forum)

	eqOp := ""
	if desc == "true" {
		eqOp = "<"
	} else {
		eqOp = ">"
	}

	if since != "" {
		query += fmt.Sprintf(" AND users.nickname %s '%s' ", eqOp, since)
	}
	query += ` ORDER BY users.nickname `

	if desc == "true" {
		query += `DESC`
	} else {
		query += `ASC`
	}

	if limit != "" {
		query += fmt.Sprintf(` LIMIT %s `, limit)
	}

	// fmt.Println(query)
	rows, err := db.Query(query)
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
