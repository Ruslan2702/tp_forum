package main

import (
	"encoding/json"
	"forum/models"
	"github.com/valyala/fasthttp"
)

func (env *Env) clearAll(ctx *fasthttp.RequestCtx) {
	models.DeleteAll(env.pool)

	ctx.SetStatusCode(fasthttp.StatusOK)
}

func (env *Env) serviceStatus(ctx *fasthttp.RequestCtx) {
	forums, threads, users, posts := models.ServiceStatus(env.pool)

	msg := map[string]int{"forum": forums, "thread": threads,
		"user": users, "post": posts}
	outStr, _ := json.Marshal(msg)
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}
