package main

import (

	// _ "database/sql"
	"database/sql"
	_ "database/sql"
	"encoding/json"
	"forum/models"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	//"github.com/mailru/easyjson"
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

	http.ListenAndServe(":5000", router)
}

func (env *Env) getPostsList(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	thread := vars["slug"]

	w.Header().Set("Content-Type", "application/json")

	var has bool
	oldThread := &models.Thread{}
	var msg map[string]string
	// var commonForum string
	var ThreadId string
	// var thrSlug string

	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.db, thread)
		// has = here
		// commonForum = oldThread.Forum
		ThreadId = thread
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, has = models.GetThreadBySlug(env.db, thread)
		// has = here
		// thrSlug = thread
		ThreadId = strconv.FormatInt(oldThread.Id, 10)
		// commonForum = oldThread.Forum
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusNotFound)
		w.Write(outStr)
		return
	}

	limit := r.FormValue("limit")
	since := r.FormValue("since")
	sort := r.FormValue("sort")
	desc := r.FormValue("desc")

	posts, has := models.GetPostsList(env.db, ThreadId, limit, since, sort, desc)

	outStr, _ := json.Marshal(posts)
	w.WriteHeader(http.StatusOK)
	w.Write(outStr)
}
