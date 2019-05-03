package main

import (
	"encoding/json"
	"forum/models"
	// "net/http"
	"github.com/valyala/fasthttp"
)

func (env *Env) clearAll(ctx *fasthttp.RequestCtx) {
	models.DeleteAll(env.db)

	// w.WriteHeader(http.StatusOK)
	ctx.SetStatusCode(fasthttp.StatusOK)
}

func (env *Env) serviceStatus(ctx *fasthttp.RequestCtx) {
	forums, threads, users, posts := models.ServiceStatus(env.db)

	msg := map[string]int{"forum": forums, "thread": threads,
		"user": users, "post": posts}
	outStr, _ := json.Marshal(msg)
	// w.WriteHeader(http.StatusOK)
	// w.Write(outStr)
	ctx.SetStatusCode(fasthttp.StatusOK)
	ctx.Write(outStr)
}
