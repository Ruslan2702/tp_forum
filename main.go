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

	// s := middleware.NewStack()
	// s.Use(myMiddleware.RespHeadersMiddleware)

	// router := httprouter.New()
	// router.POST("/forum/create/", s.Wrap(env.createForum))
	// router.POST("/forum/:forum/create", s.Wrap(env.createThread))
    // router.POST("/user/:nickname/create/", s.Wrap(env.createUser))
	// router.GET("/user/:nickname/profile/", s.Wrap(env.profileUser))
	// router.POST("/user/:nickname/profile/", s.Wrap(env.updateUser))
	// router.GET("/forum/:slug/details/", s.Wrap(env.detailsForum))
	// router.GET("/forum/:slug/threads", s.Wrap(env.getThreadsList))
	// router.POST("/thread/:slug/create", s.Wrap(env.createPost))
	// router.POST("/thread/:slug/vote", s.Wrap(env.createVote))
	// router.GET("/thread/:slug/details", s.Wrap(env.detailsThread))
	// router.POST("/thread/:slug/details", s.Wrap(env.updateThread))
	// router.GET("/forum/:slug/users", s.Wrap(env.getUsersList))
	// router.GET("/service/status", s.Wrap(env.serviceStatus))
	// router.POST("/service/clear", s.Wrap(env.clearAll))
	// router.GET("/post/:id/details", s.Wrap(env.detailsPost))
	// router.POST("/post/:id/details", s.Wrap(env.updatePost))
	// router.GET("/thread/:slug/posts", s.Wrap(env.getPostsList))

	

	http.ListenAndServe(":5000", router)
}
