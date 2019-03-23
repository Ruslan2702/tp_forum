package main

import (
	"encoding/json"
	"fmt"
	"forum/models"
	"io/ioutil"
	"net/http"
	"reflect"
	"strconv"
	"strings"

	"github.com/gorilla/mux"
)

func (env *Env) createPost(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	thread := vars["slug"]

	w.Header().Set("Content-Type", "application/json")

	posts := []*models.Post{}
	body, _ := ioutil.ReadAll(r.Body)

	json.Unmarshal(body, &posts)

	allPosts := make([]*models.Post, 0)
	savedCreated := ""

	var has bool
	var msg map[string]string
	var commonForum string
	var ThreadId int64
	var thrSlug string
	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, here := models.GetThreadById(env.db, thread)
		has = here
		commonForum = oldThread.Forum
		ThreadId, _ = strconv.ParseInt(thread, 10, 64)
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, here := models.GetThreadBySlug(env.db, thread)
		has = here
		thrSlug = thread
		ThreadId = oldThread.Id
		commonForum = oldThread.Forum
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusNotFound)
		w.Write(outStr)
		return
	}

	for _, post := range posts {
		post.Forum = commonForum
		post.Thread = ThreadId
		post.ThreadSlug = thrSlug

		_, has = models.GetUserByNickname(env.db, post.Author)
		if !has {
			msg := map[string]string{"message": "Can't find user by nickname: " + post.Author}
			outStr, _ := json.Marshal(msg)
			w.WriteHeader(http.StatusNotFound)
			w.Write(outStr)
			return
		}

		if post.Parent != 0 {
			if !models.CheckParentPost(env.db, post.Parent, post.Thread) {
				msg := map[string]string{"message": "Can't find parent post"}
				outStr, _ := json.Marshal(msg)
				w.WriteHeader(http.StatusConflict)
				w.Write(outStr)
				return
			}
		}

		resultPost := models.CreatePost(env.db, post, savedCreated)
		if savedCreated == "" {
			savedCreated = resultPost.Created
		}

		if post.Message != "" {
			allPosts = append(allPosts, resultPost)
		}
	}

	outStr, _ := json.Marshal(allPosts)

	w.WriteHeader(http.StatusCreated)
	w.Write(outStr)
}

func (env *Env) updatePost(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	postId := vars["id"]

	w.Header().Set("Content-Type", "application/json")

	var has bool

	oldPost, has := models.GetPostById(env.db, postId)

	if !has {
		msg := map[string]string{"message": "Can't find post by id: " + postId}
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusNotFound)
		w.Write(outStr)
		return
	}

	post := &models.Post{}
	body, _ := ioutil.ReadAll(r.Body)
	json.Unmarshal(body, &post)

	if post.Message != "" {
		if post.Message != oldPost.Message {
			oldPost.Message = models.UpdatePost(env.db, postId, *post)
			oldPost.IsEdited = true
		}
	}

	outStr, _ := json.Marshal(oldPost)
	w.WriteHeader(http.StatusOK)
	w.Write(outStr)
}

func (env *Env) detailsPost(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	postId := vars["id"]

	w.Header().Set("Content-Type", "application/json")

	related := r.FormValue("related")
	fmt.Println(related)
	fmt.Println(reflect.TypeOf(related))

	flagUser := false
	flagForum := false
	flagThread := false

	flags := strings.Split(related, ",")
	for _, flag := range flags {
		if flag == "user" {
			flagUser = true
		} else if flag == "thread" {
			flagThread = true
		} else if flag == "forum" {
			flagForum = true
		}
	}

	postDetail := models.PostDetails{}

	post, has := models.GetPostById(env.db, postId)
	if has {
		if flagForum {
			forum, _ := models.GetForumBySlug(env.db, post.Forum)
			postDetail.MyForum = forum
		} else {
			postDetail.MyForum = nil
		}

		if flagThread {
			thread, _ := models.GetThreadById(env.db, strconv.FormatInt(post.Thread, 10))
			postDetail.MyThread = thread
		} else {
			postDetail.MyThread = nil
		}

		if flagUser {
			author, _ := models.GetUserByNickname(env.db, post.Author)
			postDetail.MyAuthor = author
		} else {
			postDetail.MyAuthor = nil
		}

		postDetail.MyPost = post

		outStr, _ := json.Marshal(postDetail)
		w.WriteHeader(http.StatusOK)
		w.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find post by id: " + postId}
	outStr, _ := json.Marshal(msg)
	w.WriteHeader(http.StatusNotFound)
	w.Write(outStr)
}
