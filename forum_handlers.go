package main

import (
	"github.com/valyala/fasthttp"
	"encoding/json"
	"forum/models"
)

func (env *Env) detailsForum(ctx *fasthttp.RequestCtx) {
	slug := ctx.UserValue("slug").(string)

	forum, has := models.GetForumBySlug(env.pool, slug)
	if has {
		outStr, _ := forum.MarshalJSON()
		ctx.SetStatusCode(fasthttp.StatusOK)
		ctx.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find forum by slug: " + slug}
	outStr, _ := json.Marshal(msg)
	ctx.SetStatusCode(fasthttp.StatusNotFound)
	ctx.Write(outStr)
}

func (env *Env) createForum(ctx *fasthttp.RequestCtx) {
	path := ctx.UserValue("slug").(string)
	_ = path

	forum := &models.Forum{}
	forum.UnmarshalJSON(ctx.PostBody())

	user, has := models.GetUserByNickname(env.pool, forum.User)
	if !has {

		msg := map[string]string{"message": "Can't find user by nickname: " + forum.User}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	forum.User = user.Nickname

	oldForum, has := models.GetForumBySlug(env.pool, forum.Slug)
	if has {
		outStr, _ := oldForum.MarshalJSON()
		ctx.SetStatusCode(fasthttp.StatusConflict)
		ctx.Write(outStr)
		return
	}

	models.CreateForum(env.pool, forum)
	outStr, _ := forum.MarshalJSON()
	ctx.SetStatusCode(fasthttp.StatusCreated)
	ctx.Write(outStr)
}
