package main

import (
	"database/sql"
	_ "database/sql"
	"forum/models"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	"forum/middleware"
)

type Env struct {
	db *sql.DB
}

func main() {
	// db, err := models.NewDB("postgres://ruslan_shahaev:@localhost:5432/forum?sslmode=disable&connect_timeout=10")
	db, err := models.NewDB("postgres://docker:docker@localhost/docker")
	if err != nil {
		log.Panic(err)
	}
	defer db.Close()

	env := &Env{db: db}

	router := mux.NewRouter()
	router.HandleFunc("/api/user/{nickname}/create", env.createUser).Methods("POST")
	router.HandleFunc("/api/user/{nickname}/profile", env.profileUser).Methods("GET")
	router.HandleFunc("/api/user/{nickname}/profile", env.updateUser).Methods("POST")
	router.HandleFunc("/api/forum/create", env.createForum).Methods("POST")
	router.HandleFunc("/api/forum/{slug}/details", env.detailsForum).Methods("GET")
	router.HandleFunc("/api/forum/{slug}/create", env.createThread).Methods("POST")
	router.HandleFunc("/api/forum/{slug}/threads", env.getThreadsList).Methods("GET")
	router.HandleFunc("/api/thread/{slug}/create", env.createPost).Methods("POST")
	router.HandleFunc("/api/thread/{slug}/vote", env.createVote).Methods("POST")
	router.HandleFunc("/api/thread/{slug}/details", env.detailsThread).Methods("GET")
	router.HandleFunc("/api/thread/{slug}/details", env.updateThread).Methods("POST")
	router.HandleFunc("/api/forum/{slug}/users", env.getUsersList).Methods("GET")
	router.HandleFunc("/api/service/status", env.serviceStatus).Methods("GET")
	router.HandleFunc("/api/service/clear", env.clearAll).Methods("POST")
	router.HandleFunc("/api/post/{id}/details", env.detailsPost).Methods("GET")
	router.HandleFunc("/api/post/{id}/details", env.updatePost).Methods("POST")
	router.HandleFunc("/api/thread/{slug}/posts", env.getPostsList).Methods("GET")

	router.Use(middleware.RespHeadersMiddleware)

	http.ListenAndServe(":5000", router)
}
