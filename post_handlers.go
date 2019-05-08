package main

import (
	"github.com/valyala/fasthttp"
	"time"
	"encoding/json"
	"forum/models"
	"strconv"
	"strings"
)

func (env *Env) createPost(ctx *fasthttp.RequestCtx) {
	thread := ctx.UserValue("slug").(string)

	posts := models.Posts{}
	posts.UnmarshalJSON(ctx.PostBody())

	var has bool
	var msg map[string]string
	var commonForum string
	var ThreadId int64
	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, here := models.GetThreadById(env.pool, thread)
		has = here
		commonForum = oldThread.Forum
		ThreadId, _ = strconv.ParseInt(thread, 10, 64)
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, here := models.GetThreadBySlug(env.pool, thread)
		has = here
		ThreadId = oldThread.Id
		commonForum = oldThread.Forum
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	user := &models.User{}
	if len(posts) > 0 {
		post := posts[0]
		user, has = models.GetUserByNickname(env.pool, post.Author)
		if !has {
			msg := map[string]string{"message": "Can't find user by nickname: " + post.Author}
			outStr, _ := json.Marshal(msg)
			ctx.SetStatusCode(fasthttp.StatusNotFound)
			ctx.Write(outStr)
			return
		}
		
		if post.Parent != 0 {
			if !models.CheckParentPost(env.pool, post.Parent, ThreadId) {
				msg := map[string]string{"message": "Can't find parent post"}
				outStr, _ := json.Marshal(msg)
				ctx.SetStatusCode(fasthttp.StatusConflict)
				ctx.Write(outStr)
				return
			}
		}
	}

	created := time.Now().Format(time.RFC3339Nano)

	err := models.CreatePost(env.pool, posts, created, ThreadId, commonForum, user)
	if err != nil {
		msg := map[string]string{"message": "Can't find parent post"}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusConflict)
		ctx.Write(outStr)
		return
	}

	outStr, _ := models.Posts(posts).MarshalJSON()

	ctx.SetStatusCode(fasthttp.StatusCreated)
	ctx.Write(outStr)
}


func (env *Env) updatePost(ctx *fasthttp.RequestCtx) {
	postId := ctx.UserValue("id").(string)

	var has bool
	oldPost, has := models.GetPostById(env.pool, postId)

	if !has {
		msg := map[string]string{"message": "Can't find post by id: " + postId}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	post := &models.Post{}
	post.UnmarshalJSON(ctx.PostBody())

	if post.Message != "" {
		if post.Message != oldPost.Message {
			oldPost.Message = models.UpdatePost(env.pool, postId, *post)
			oldPost.IsEdited = true
		}
	}

	outStr, _ := oldPost.MarshalJSON()
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}

func (env *Env) detailsPost(ctx *fasthttp.RequestCtx) {
	postId := ctx.UserValue("id").(string)

	related := string(ctx.FormValue("related"))

	flagUser := false
	flagForum := false
	flagThread := false

	flags := strings.Split(related, ",")
	for _, flag := range flags {
		if flag == "user" {
			flagUser = true
		} else if flag == "thread" {
			flagThread = true
		} else if flag == "forum" {
			flagForum = true
		}
	}

	postDetail := models.PostDetails{}

	post, has := models.GetPostById(env.pool, postId)
	if has {
		if flagForum {
			forum, _ := models.GetForumBySlug(env.pool, post.Forum)
			postDetail.MyForum = forum
		} else {
			postDetail.MyForum = nil
		}

		if flagThread {
			thread, _ := models.GetThreadById(env.pool, strconv.FormatInt(post.Thread, 10))
			postDetail.MyThread = thread
		} else {
			postDetail.MyThread = nil
		}

		if flagUser {
			author, _ := models.GetUserByNickname(env.pool, post.Author)
			postDetail.MyAuthor = author
		} else {
			postDetail.MyAuthor = nil
		}

		postDetail.MyPost = post

		outStr, _ := postDetail.MarshalJSON()
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find post by id: " + postId}
	outStr, _ := json.Marshal(msg)
	ctx.SetStatusCode(fasthttp.StatusNotFound)
	ctx.Write(outStr)
}


func (env *Env) getPostsList(ctx *fasthttp.RequestCtx) {
	thread := ctx.UserValue("slug").(string)

	var has bool
	oldThread := &models.Thread{}
	var msg map[string]string
	var ThreadId string

	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.pool, thread)
		ThreadId = thread
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, has = models.GetThreadBySlug(env.pool, thread)
		ThreadId = strconv.FormatInt(oldThread.Id, 10)
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	limit := string(ctx.FormValue("limit"))
	since := string(ctx.FormValue("since"))
	sort := string(ctx.FormValue("sort"))
	desc := string(ctx.FormValue("desc"))

	posts, _ := models.GetPostsList(env.pool, ThreadId, limit, since, sort, desc)

	outStr, _ := json.Marshal(posts)
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}
