package main

import (
	"forum/models"
	"forum/middleware"

	"github.com/jackc/pgx"

	"github.com/buaazp/fasthttprouter"
	"github.com/valyala/fasthttp"
)


type Env struct {
	pool *pgx.ConnPool 
}

func main() {
	// pool := models.NewPool("localhost", 5432, "ruslan_shahaev", "", "forum", 30)
	pool := models.NewPool("localhost", 5432, "docker", "docker", "docker", 30)

	env := &Env{pool: pool}
	defer pool.Close()

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


	fasthttp.ListenAndServe(":5000", router.Handler)
}
