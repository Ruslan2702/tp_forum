package middleware

import (
	"github.com/valyala/fasthttp"
	// // "net/http"
)

// func RespHeadersMiddleware(next http.Handler) http.Handler {
// 	return http.HandlerFunc(func(ctx *fasthttp.RequestCtx) {
// 		w.Header().Set("Content-Type", "application/json")
// 		next.ServeHTTP(w, r)
// 	})
// }

func RespHeadersMiddleware(next fasthttp.RequestHandler) fasthttp.RequestHandler {
    return func(ctx *fasthttp.RequestCtx) {
		next(ctx)
		
		ctx.Response.Header.Set("Content-Type", "application/json")
    }
}
