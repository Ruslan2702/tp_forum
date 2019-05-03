package main

import (
	"encoding/json"
	"forum/models"
	// "io/ioutil"
	// "net/http"
	"strconv"

	// "github.com/gorilla/mux"
	"github.com/valyala/fasthttp"
)

func (env *Env) getThreadsList(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// forum := vars["slug"]

	forum := ctx.UserValue("slug").(string)

	oldForum, has := models.GetForumBySlug(env.db, forum)
	if !has {
		msg := map[string]string{"message": "Can't find forum by slug: " + forum}
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusNotFound)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	forum = oldForum.Slug

	// limit := r.FormValue("limit")
	// since := r.FormValue("since")
	// desc := r.FormValue("desc")

	limit := string(ctx.FormValue("limit"))
	since := string(ctx.FormValue("since"))
	desc := string(ctx.FormValue("desc"))

	threads, has := models.GetForumThreads(env.db, forum, limit, since, desc)

	if has {
		outStr, _ := json.Marshal(threads)
		// w.WriteHeader(http.StatusOK)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}
}

func (env *Env) createThread(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// forum := vars["slug"]

	forum := ctx.UserValue("slug").(string)

	thread := &models.Thread{}
	// body, _ := ioutil.ReadAll(r.Body)
	// json.Unmarshal(body, thread)
	thread.UnmarshalJSON(ctx.PostBody())
	thread.Forum = forum

	_, has := models.GetUserByNickname(env.db, thread.Author)
	if !has {
		msg := map[string]string{"message": "Can't find user by nickname: " + thread.Author}
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusNotFound)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	oldForum, has := models.GetForumBySlug(env.db, forum)
	if !has {
		msg := map[string]string{"message": "Can't find forum by slug: " + forum}
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusNotFound)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	thread.Forum = oldForum.Slug

	if thread.Slug != "" {
		oldThread, has := models.GetThreadBySlug(env.db, thread.Slug)
		if has {
			// outStr, _ := json.Marshal(oldThread)
			outStr, _ := oldThread.MarshalJSON()
			// w.WriteHeader(http.StatusConflict)
			// w.Write(outStr)
			ctx.SetStatusCode(fasthttp.StatusConflict)
			ctx.Write(outStr)
			return
		}
	}

	_ = models.CreateThread(env.db, thread)
	// fmt.Println(err)

	// w.WriteHeader(http.StatusCreated)
	// outStr, _ := json.Marshal(thread)
	outStr, _ := thread.MarshalJSON()
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusCreated)
	ctx.Write(outStr)
}

func (env *Env) updateThread(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// thread := vars["slug"]

	thread := ctx.UserValue("slug").(string)

	var has bool
	oldThread := &models.Thread{}
	var msg map[string]string
	// var commonForum string
	var ThreadId int64
	// var thrSlug string

	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.db, thread)
		// has = here
		// commonForum = oldThread.Forum
		ThreadId, _ = strconv.ParseInt(thread, 10, 64)
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, has = models.GetThreadBySlug(env.db, thread)
		// has = here
		// thrSlug = thread
		ThreadId = oldThread.Id
		// commonForum = oldThread.Forum
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusNotFound)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	newThread := &models.Thread{}
	// body, _ := ioutil.ReadAll(r.Body)
	// json.Unmarshal(body, &newThread)
	newThread.UnmarshalJSON(ctx.PostBody())

	models.UpdateThread(env.db, ThreadId, newThread, oldThread)

	// outStr, _ := json.Marshal(oldThread)
	outStr, _ := oldThread.MarshalJSON()
	// w.WriteHeader(http.StatusOK)
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}

func (env *Env) detailsThread(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// thread := vars["slug"]

	thread := ctx.UserValue("slug").(string)

	var has bool
	oldThread := &models.Thread{}
	var msg map[string]string
	// var commonForum string
	// var ThreadId int64
	// var thrSlug string

	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.db, thread)
		// has = here
		// commonForum = oldThread.Forum
		// ThreadId, _ = strconv.ParseInt(thread, 10, 64)
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, has = models.GetThreadBySlug(env.db, thread)
		// has = here
		// thrSlug = thread
		// ThreadId = oldThread.Id
		// commonForum = oldThread.Forum
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusNotFound)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	// outStr, _ := json.Marshal(oldThread)
	outStr, _ := oldThread.MarshalJSON()
	// w.WriteHeader(http.StatusOK)
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}
