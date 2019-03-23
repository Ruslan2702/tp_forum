package main

import (
	"encoding/json"
	"forum/models"
	"io/ioutil"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

func (env *Env) createVote(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	thread := vars["slug"]

	w.Header().Set("Content-Type", "application/json")

	vote := &models.Vote{}
	body, _ := ioutil.ReadAll(r.Body)

	json.Unmarshal(body, vote)

	has := false
	oldThread := &models.Thread{}
	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.db, thread)
	} else {
		oldThread, has = models.GetThreadBySlug(env.db, thread)
	}

	if !has {
		msg := map[string]string{"message": "Can't find thread"}
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusNotFound)
		w.Write(outStr)
		return
	}

	_, has = models.GetUserByNickname(env.db, vote.Nickname)
	if !has {
		msg := map[string]string{"message": "Can't find user by nickname: " + vote.Nickname}
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusNotFound)
		w.Write(outStr)
		return
	}

	vote.Thread = oldThread.Id

	_, val := models.CreateVote(env.db, vote)
	oldThread.Votes = val

	outStr, _ := json.Marshal(oldThread)

	w.WriteHeader(http.StatusOK)
	w.Write(outStr)
}
