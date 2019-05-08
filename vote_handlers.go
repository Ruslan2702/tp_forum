package main

import (
	"encoding/json"
	"forum/models"
	"strconv"
	"github.com/valyala/fasthttp"
)

func (env *Env) createVote(ctx *fasthttp.RequestCtx) {
	thread := ctx.UserValue("slug").(string)

	vote := &models.Vote{}
	vote.UnmarshalJSON(ctx.PostBody())

	has := false
	oldThread := &models.Thread{}
	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.pool, thread)
	} else {
		oldThread, has = models.GetThreadBySlug(env.pool, thread)
	}

	if !has {
		msg := map[string]string{"message": "Can't find thread"}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	_, has = models.GetUserByNickname(env.pool, vote.Nickname)
	if !has {
		msg := map[string]string{"message": "Can't find user by nickname: " + vote.Nickname}
		outStr, _ := json.Marshal(msg)
		ctx.SetStatusCode(fasthttp.StatusNotFound)
		ctx.Write(outStr)
		return
	}

	vote.Thread = oldThread.Id

	_, val := models.CreateVote(env.pool, vote)
	oldThread.Votes = val

	outStr, _ := oldThread.MarshalJSON()

	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}
