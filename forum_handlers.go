package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"

	"forum/models"

	"github.com/gorilla/mux"
)

func (env *Env) detailsForum(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	slug := vars["slug"]

	forum, has := models.GetForumBySlug(env.db, slug)
	if has {
		// outStr, _ := json.Marshal(forum)
		outStr, _ := forum.MarshalJSON()
		w.WriteHeader(http.StatusOK)
		w.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find forum by slug: " + slug}
	outStr, _ := json.Marshal(msg)
	w.WriteHeader(http.StatusNotFound)
	w.Write(outStr)
}

func (env *Env) createForum(w http.ResponseWriter, r *http.Request) {
	forum := &models.Forum{}
	body, _ := ioutil.ReadAll(r.Body)
	// json.Unmarshal(body, &forum)
	forum.UnmarshalJSON(body)

	user, has := models.GetUserByNickname(env.db, forum.User)
	if !has {

		msg := map[string]string{"message": "Can't find user by nickname: " + forum.User}
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusNotFound)
		w.Write(outStr)
		return
	}

	forum.User = user.Nickname

	oldForum, has := models.GetForumBySlug(env.db, forum.Slug)
	if has {
		// outStr, _ := json.Marshal(oldForum)
		outStr, _ := oldForum.MarshalJSON()
		w.WriteHeader(http.StatusConflict)
		w.Write(outStr)
		return
	}

	models.CreateForum(env.db, forum)
	// outStr, _ := json.Marshal(forum)
	outStr, _ := forum.MarshalJSON()
	w.WriteHeader(http.StatusCreated)
	w.Write(outStr)
}
