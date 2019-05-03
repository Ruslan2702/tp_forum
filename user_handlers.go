package main

import (
	"github.com/valyala/fasthttp"
	"encoding/json"
	"forum/models"
	// "io/ioutil"
	// // "net/http"

	// // "github.com/gorilla/mux"
)

func (env *Env) updateUser(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// nickname := vars["nickname"]

	nickname := ctx.UserValue("nickname").(string)

	user := &models.User{}
	// body, _ := ioutil.ReadAll(r.Body)
	// // json.Unmarshal(body, &user)
	// user.UnmarshalJSON(body)

	user.UnmarshalJSON(ctx.PostBody())
	user.Nickname = nickname

	_, has := models.GetUserByNickname(env.db, nickname)
	if !has {
		msg := map[string]string{"message": "Can't find user by nickname: " + nickname}
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusNotFound)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	_, has = models.GetUserByEmail(env.db, user.Email)
	if has {
		msg := map[string]string{"message": "Conflict"}
		outStr, _ := json.Marshal(msg)
		// w.WriteHeader(http.StatusConflict)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusConflict)
		ctx.Write(outStr)
		return
	}

	models.UpdateUser(env.db, user)

	// outStr, _ := json.Marshal(user)
	outStr, _ := user.MarshalJSON()
	// w.WriteHeader(http.StatusOK)
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}

func (env *Env) profileUser(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// nickname := vars["nickname"]

	nickname := ctx.UserValue("nickname").(string)

	user, has := models.GetUserByNickname(env.db, nickname)
	if has {
		// outStr, _ := json.Marshal(user)
		outStr, _ := user.MarshalJSON()
		// w.WriteHeader(http.StatusOK)
		// w.Write(outStr)
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find user by nickname: " + nickname}
	outStr, _ := json.Marshal(msg)
	// w.WriteHeader(http.StatusNotFound)
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusNotFound)
	ctx.Write(outStr)
}

func (env *Env) createUser(ctx *fasthttp.RequestCtx) {
	// vars := mux.Vars(r)
	// nickname := vars["nickname"]

	nickname := ctx.UserValue("nickname").(string)

	user := models.User{}
	// body, _ := ioutil.ReadAll(r.Body)
	// body, _ := ioutil.ReadAll(ctx.Request.Body())
	
	// json.Unmarshal(body, &user)
	user.UnmarshalJSON(ctx.PostBody())
	user.Nickname = nickname

	users, added := models.CreateUser(env.db, &user)

	var outStr []byte
	if added {
		outStr, _ = json.Marshal(*users[0])
		// w.WriteHeader(http.StatusCreated)
		ctx.SetStatusCode(fasthttp.StatusCreated)
	} else {
		outStr, _ = json.Marshal(users)
		// w.WriteHeader(http.StatusConflict)
		ctx.SetStatusCode(fasthttp.StatusConflict)
	}

	// w.Write(outStr)
	ctx.Write(outStr)
}

func (env *Env) getUsersList(ctx *fasthttp.RequestCtx) {
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

	users, has := models.GetForumUsers(env.db, forum, limit, since, desc)

	if has {
		outStr, _ := json.Marshal(users)
		// w.WriteHeader(http.StatusOK)
		// w.Write(outStr)

		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}
}
