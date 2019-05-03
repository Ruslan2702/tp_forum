package main

import (
	"github.com/valyala/fasthttp"
	"encoding/json"
	// "io/ioutil"
	// "net/http"

	"forum/models"

	// "github.com/gorilla/mux"
)

func (env *Env) detailsForum(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// slug := vars["slug"]

	slug := ctx.UserValue("slug").(string)

	forum, has := models.GetForumBySlug(env.db, slug)
	if has {
		// outStr, _ := json.Marshal(forum)
		outStr, _ := forum.MarshalJSON()
		// w.WriteHeader(http.StatusOK)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find forum by slug: " + slug}
	outStr, _ := json.Marshal(msg)
	// w.WriteHeader(http.StatusNotFound)
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusNotFound)
	ctx.Write(outStr)
}

func (env *Env) createForum(ctx *fasthttp.RequestCtx) {
	path := ctx.UserValue("slug").(string)
	_ = path

	forum := &models.Forum{}
	// body, _ := ioutil.ReadAll(r.Body)
	// json.Unmarshal(body, &forum)
	forum.UnmarshalJSON(ctx.PostBody())

	user, has := models.GetUserByNickname(env.db, forum.User)
	if !has {

		msg := map[string]string{"message": "Can't find user by nickname: " + forum.User}
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusNotFound)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	forum.User = user.Nickname

	oldForum, has := models.GetForumBySlug(env.db, forum.Slug)
	if has {
		// outStr, _ := json.Marshal(oldForum)
		outStr, _ := oldForum.MarshalJSON()
		// w.WriteHeader(http.StatusConflict)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusConflict)
		ctx.Write(outStr)
		return
	}

	models.CreateForum(env.db, forum)
	// outStr, _ := json.Marshal(forum)
	outStr, _ := forum.MarshalJSON()
	// w.WriteHeader(http.StatusCreated)
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusCreated)
	ctx.Write(outStr)
}
