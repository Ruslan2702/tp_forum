package middleware

import (
	"github.com/valyala/fasthttp"
)

func RespHeadersMiddleware(next fasthttp.RequestHandler) fasthttp.RequestHandler {
    return func(ctx *fasthttp.RequestCtx) {
		next(ctx)
		
		ctx.Response.Header.Set("Content-Type", "application/json")
    }
}
