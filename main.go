package main

import (
	// "fmt"
	"database/sql"
	"forum/models"
	"log"
	// // "net/http"
	// // "github.com/gorilla/mux"
	_ "github.com/lib/pq"
	"forum/middleware"

	// "github.com/jackc/pgx"

	"github.com/buaazp/fasthttprouter"
	"github.com/valyala/fasthttp"
)


type Env struct {
	db *sql.DB
	// db *sql.DB
}

func main() {
	// db, err := models.NewDB("postgres://ruslan_shahaev:@localhost:5432/forum?sslmode=disable&connect_timeout=10")
	db, err := models.NewDB("postgres://docker:docker@localhost/docker")
	// conn := Connect("connect test")
	// defer conn.Close()
	if err != nil {
		log.Panic(err)
	}
	// defer db.Close()

	env := &Env{db: db}

	// pool, _ := pgx.NewConnPool(sql.DBConfig{
	// 	ConnConfig: pgx.ConnConfig{
	// 		Host:     "localhost",
	// 		Port:     5432,
	// 		User:     "ruslan_shahaev",
	// 		Password: "",
	// 		Database: "forum",
	// 	},
	// 	MaxConnections: 30,
	// })
	// pool, _ := pgx.NewConnPool(sql.DBConfig{
	// 	ConnConfig: pgx.ConnConfig{
	// 		Host:     "localhost",
	// 		Port:     5432,
	// 		User:     "docker",
	// 		Password: "docker",
	// 		Database: "docker",
	// 	},
	// 	MaxConnections: 30,
	// })

	// env := &Env{db: pool}
	// defer pool.Close()

	var router = fasthttprouter.New()



	router.POST("/api/user/:nickname/create", middleware.RespHeadersMiddleware(env.createUser))
	router.GET("/api/user/:nickname/profile", middleware.RespHeadersMiddleware(env.profileUser))
	router.POST("/api/user/:nickname/profile", middleware.RespHeadersMiddleware(env.updateUser))

	router.POST("/api/forum/:slug", middleware.RespHeadersMiddleware(env.createForum))
	router.POST("/api/forum/:slug/create", middleware.RespHeadersMiddleware(env.createThread))
	router.GET("/api/forum/:slug/details", middleware.RespHeadersMiddleware(env.detailsForum))
	router.GET("/api/forum/:slug/threads", middleware.RespHeadersMiddleware(env.getThreadsList))
	router.GET("/api/forum/:slug/users", middleware.RespHeadersMiddleware(env.getUsersList))

	router.POST("/api/thread/:slug/create", middleware.RespHeadersMiddleware(env.createPost))
	router.POST("/api/thread/:slug/vote", middleware.RespHeadersMiddleware(env.createVote))
	router.GET("/api/thread/:slug/details", middleware.RespHeadersMiddleware(env.detailsThread))
	router.POST("/api/thread/:slug/details", middleware.RespHeadersMiddleware(env.updateThread))
	router.GET("/api/thread/:slug/posts", middleware.RespHeadersMiddleware(env.getPostsList))

	router.GET("/api/service/status", middleware.RespHeadersMiddleware(env.serviceStatus))
	router.POST("/api/service/clear", middleware.RespHeadersMiddleware(env.clearAll))

	router.GET("/api/post/:id/details", middleware.RespHeadersMiddleware(env.detailsPost))
	router.POST("/api/post/:id/details", middleware.RespHeadersMiddleware(env.updatePost))

	// router := mux.NewRouter()
	// router.HandleFunc("/api/user/{nickname}/create", env.createUser).Methods("POST")
	// router.HandleFunc("/api/user/{nickname}/profile", env.profileUser).Methods("GET")
	// router.HandleFunc("/api/user/{nickname}/profile", env.updateUser).Methods("POST")
	// router.HandleFunc("/api/forum/create", env.createForum).Methods("POST")

	// router.HandleFunc("/api/forum/{slug}/details", env.detailsForum).Methods("GET")
	// router.HandleFunc("/api/forum/{slug}/create", env.createThread).Methods("POST")
	// router.HandleFunc("/api/forum/{slug}/threads", env.getThreadsList).Methods("GET")
	// router.HandleFunc("/api/thread/{slug}/create", env.createPost).Methods("POST")
	// router.HandleFunc("/api/thread/{slug}/vote", env.createVote).Methods("POST")
	// router.HandleFunc("/api/thread/{slug}/details", env.detailsThread).Methods("GET")
	// router.HandleFunc("/api/thread/{slug}/details", env.updateThread).Methods("POST")
	// router.HandleFunc("/api/forum/{slug}/users", env.getUsersList).Methods("GET")
	// router.HandleFunc("/api/service/status", env.serviceStatus).Methods("GET")
	// router.HandleFunc("/api/service/clear", env.clearAll).Methods("POST")
	// router.HandleFunc("/api/post/{id}/details", env.detailsPost).Methods("GET")
	// router.HandleFunc("/api/post/{id}/details", env.updatePost).Methods("POST")
	// router.HandleFunc("/api/thread/{slug}/posts", env.getPostsList).Methods("GET")

	// router.Use(middleware.RespHeadersMiddleware)

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

	

	// http.ListenAndServe(":5000", router)
	fasthttp.ListenAndServe(":5000", router.Handler)
}
