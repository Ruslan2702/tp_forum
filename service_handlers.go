package main

import (
	"encoding/json"
	"forum/models"
	"net/http"
)

func (env *Env) clearAll(w http.ResponseWriter, r *http.Request) {
	models.DeleteAll(env.db)

	w.WriteHeader(http.StatusOK)
}

func (env *Env) serviceStatus(w http.ResponseWriter, r *http.Request) {
	forums, threads, users, posts := models.ServiceStatus(env.db)

	msg := map[string]int{"forum": forums, "thread": threads,
		"user": users, "post": posts}
	outStr, _ := json.Marshal(msg)
	w.WriteHeader(http.StatusOK)
	w.Write(outStr)
}
