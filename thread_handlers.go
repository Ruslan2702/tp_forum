package main

import (
	"encoding/json"
	"forum/models"
	"strconv"
	"github.com/valyala/fasthttp"
)

func (env *Env) getThreadsList(ctx *fasthttp.RequestCtx) {
	forum := ctx.UserValue("slug").(string)

	oldForum, has := models.GetForumBySlug(env.pool, forum)
	if !has {
		msg := map[string]string{"message": "Can't find forum by slug: " + forum}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	forum = oldForum.Slug

	limit := string(ctx.FormValue("limit"))
	since := string(ctx.FormValue("since"))
	desc := string(ctx.FormValue("desc"))

	threads, has := models.GetForumThreads(env.pool, forum, limit, since, desc)

	if has {
		outStr, _ := json.Marshal(threads)
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}
}

func (env *Env) createThread(ctx *fasthttp.RequestCtx) {
	forum := ctx.UserValue("slug").(string)

	thread := &models.Thread{}
	thread.UnmarshalJSON(ctx.PostBody())
	thread.Forum = forum

	_, has := models.GetUserByNickname(env.pool, thread.Author)
	if !has {
		msg := map[string]string{"message": "Can't find user by nickname: " + thread.Author}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	oldForum, has := models.GetForumBySlug(env.pool, forum)
	if !has {
		msg := map[string]string{"message": "Can't find forum by slug: " + forum}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	thread.Forum = oldForum.Slug

	if thread.Slug != "" {
		oldThread, has := models.GetThreadBySlug(env.pool, thread.Slug)
		if has {
			outStr, _ := oldThread.MarshalJSON()
			ctx.SetStatusCode(fasthttp.StatusConflict)
			ctx.Write(outStr)
			return
		}
	}

	_ = models.CreateThread(env.pool, thread)
	outStr, _ := thread.MarshalJSON()
	ctx.SetStatusCode(fasthttp.StatusCreated)
	ctx.Write(outStr)
}

func (env *Env) updateThread(ctx *fasthttp.RequestCtx) {
	thread := ctx.UserValue("slug").(string)

	var has bool
	oldThread := &models.Thread{}
	var msg map[string]string
	var ThreadId int64

	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.pool, thread)
		ThreadId, _ = strconv.ParseInt(thread, 10, 64)
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, has = models.GetThreadBySlug(env.pool, thread)
		ThreadId = oldThread.Id
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	newThread := &models.Thread{}
	newThread.UnmarshalJSON(ctx.PostBody())

	models.UpdateThread(env.pool, ThreadId, newThread, oldThread)

	outStr, _ := oldThread.MarshalJSON()
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}

func (env *Env) detailsThread(ctx *fasthttp.RequestCtx) {
	thread := ctx.UserValue("slug").(string)

	var has bool
	oldThread := &models.Thread{}
	var msg map[string]string

	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.pool, thread)
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, has = models.GetThreadBySlug(env.pool, thread)
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	outStr, _ := oldThread.MarshalJSON()
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}
