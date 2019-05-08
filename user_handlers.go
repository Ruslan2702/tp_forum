package main

import (
	"github.com/valyala/fasthttp"
	"encoding/json"
	"forum/models"
)

func (env *Env) updateUser(ctx *fasthttp.RequestCtx) {
	nickname := ctx.UserValue("nickname").(string)

	user := &models.User{}
	user.UnmarshalJSON(ctx.PostBody())
	user.Nickname = nickname

	_, has := models.GetUserByNickname(env.pool, nickname)
	if !has {
		msg := map[string]string{"message": "Can't find user by nickname: " + nickname}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	_, has = models.GetUserByEmail(env.pool, user.Email)
	if has {
		msg := map[string]string{"message": "Conflict"}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusConflict)
		ctx.Write(outStr)
		return
	}

	models.UpdateUser(env.pool, user)

	outStr, _ := user.MarshalJSON()
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}

func (env *Env) profileUser(ctx *fasthttp.RequestCtx) {
	nickname := ctx.UserValue("nickname").(string)

	user, has := models.GetUserByNickname(env.pool, nickname)
	if has {
		outStr, _ := user.MarshalJSON()
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find user by nickname: " + nickname}
	outStr, _ := json.Marshal(msg)
	ctx.SetStatusCode(fasthttp.StatusNotFound)
	ctx.Write(outStr)
}

func (env *Env) createUser(ctx *fasthttp.RequestCtx) {
	nickname := ctx.UserValue("nickname").(string)

	user := models.User{}
	user.UnmarshalJSON(ctx.PostBody())
	user.Nickname = nickname

	users, added := models.CreateUser(env.pool, &user)

	var outStr []byte
	if added {
		outStr, _ = json.Marshal(*users[0])
		ctx.SetStatusCode(fasthttp.StatusCreated)
	} else {
		outStr, _ = json.Marshal(users)
		ctx.SetStatusCode(fasthttp.StatusConflict)
	}

	ctx.Write(outStr)
}

func (env *Env) getUsersList(ctx *fasthttp.RequestCtx) {
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

	users, has := models.GetForumUsers(env.pool, forum, limit, since, desc)

	if has {
		outStr, _ := json.Marshal(users)
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}
}
