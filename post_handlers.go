package main

import (
	"time"
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

	// posts := []*models.Post{}
	posts := models.Posts{}
	body, _ := ioutil.ReadAll(r.Body)

	// json.Unmarshal(body, &posts)
	posts.UnmarshalJSON(body)
	// posts.UnmarshalJSON(body)

	// allPosts := make([]*models.Post, 0)
	// allPosts := models.Post{}
	// savedCreated := ""

	var has bool
	var msg map[string]string
	var commonForum string
	var ThreadId int64
	// var thrSlug string
	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, here := models.GetThreadById(env.db, thread)
		has = here
		commonForum = oldThread.Forum
		ThreadId, _ = strconv.ParseInt(thread, 10, 64)
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, here := models.GetThreadBySlug(env.db, thread)
		has = here
		// thrSlug = thread
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

	if len(posts) > 0 {
		post := posts[0]
		_, has = models.GetUserByNickname(env.db, post.Author)
		if !has {
			msg := map[string]string{"message": "Can't find user by nickname: " + post.Author}
			outStr, _ := json.Marshal(msg)
			w.WriteHeader(http.StatusNotFound)
			w.Write(outStr)
			return
		}
	}

	created := time.Now().Format(time.RFC3339Nano)

	// for _, post := range posts {
	// 	post.Forum = commonForum
	// 	post.Thread = ThreadId
	// 	post.ThreadSlug = thrSlug
	// 	if post.Created == "" {
	// 		post.Created = created
	// 	}

		// _, has = models.GetUserByNickname(env.db, post.Author)
		// if !has {
		// 	msg := map[string]string{"message": "Can't find user by nickname: " + post.Author}
		// 	outStr, _ := json.Marshal(msg)
		// 	w.WriteHeader(http.StatusNotFound)
		// 	w.Write(outStr)
		// 	return
		// }

	// 	if post.Parent != 0 {
	// 		if !models.CheckParentPost(env.db, post.Parent, post.Thread) {
	// 			msg := map[string]string{"message": "Can't find parent post"}
	// 			outStr, _ := json.Marshal(msg)
	// 			w.WriteHeader(http.StatusConflict)
	// 			w.Write(outStr)
	// 			return
	// 		}
	// 	}

	err := models.CreatePost(env.db, posts, created, ThreadId, commonForum)
	if err != nil {
		msg := map[string]string{"message": "Can't find parent post"}
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusConflict)
		w.Write(outStr)
		return
	}

	// 	if post.Message != "" {
	// 		allPosts = append(allPosts, post)
	// 	}
	// }

	// (allPosts).(models.Posts)
	// outStr, _ := json.Marshal(allPosts)
	outStr, _ := models.Posts(posts).MarshalJSON()

	w.WriteHeader(http.StatusCreated)
	w.Write(outStr)
}

// func (env *Env) createPost(w http.ResponseWriter, r *http.Request) {
// 	vars := mux.Vars(r)
// 	thread := vars["slug"]

// 	posts := make([]*models.Post, 0)
// 	body, _ := ioutil.ReadAll(r.Body)

// 	json.Unmarshal(body, &posts)

// 	// allPosts := make([]*models.Post, 0)

// 	var has bool
// 	var msg map[string]string
// 	var commonForum string
// 	var ThreadId int64
// 	// var thrSlug string
// 	if _, err := strconv.Atoi(thread); err == nil {
// 		oldThread, here := models.GetThreadById(env.db, thread)
// 		has = here
// 		commonForum = oldThread.Forum
// 		ThreadId, _ = strconv.ParseInt(thread, 10, 64)
// 		msg = map[string]string{"message": "Can't find thread by id: " + thread}
// 	} else {
// 		oldThread, here := models.GetThreadBySlug(env.db, thread)
// 		has = here
// 		// thrSlug = thread
// 		ThreadId = oldThread.Id
// 		commonForum = oldThread.Forum
// 		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
// 	}

// 	if !has {
// 		outStr, _ := json.Marshal(msg)
// 		w.WriteHeader(http.StatusNotFound)
// 		w.Write(outStr)
// 		return
// 	}

// 	// for _, post := range posts {
// 	// 	post.Forum = commonForum
// 	// 	post.Thread = ThreadId
// 	// 	post.ThreadSlug = thrSlug

// 	// _, has = models.GetUserByNickname(env.db, posts[0].Author)
// 	// if !has {
// 	// 	msg := map[string]string{"message": "Can't find user by nickname: " + post.Author}
// 	// 	outStr, _ := json.Marshal(msg)
// 	// 	w.WriteHeader(http.StatusNotFound)
// 	// 	w.Write(outStr)
// 	// 	return
// 	// }

// 		// if post.Parent != 0 {
// 		// 	if !models.CheckParentPost(env.db, post.Parent, post.Thread) {
// 		// 		msg := map[string]string{"message": "Can't find parent post"}
// 		// 		outStr, _ := json.Marshal(msg)
// 		// 		w.WriteHeader(http.StatusConflict)
// 		// 		w.Write(outStr)
// 		// 		return
// 		// 	}
// 		// }

// 	models.CreatePost(env.db, posts, ThreadId, commonForum, time.Now().Format(time.UnixDate))

// 		// if post.Message != "" {
// 		// 	allPosts = append(allPosts, resultPost)
// 		// }
	

// 	outStr, _ := json.Marshal(posts)

// 	w.WriteHeader(http.StatusCreated)
// 	w.Write(outStr)
// }


func (env *Env) updatePost(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	postId := vars["id"]

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
	// json.Unmarshal(body, &post)
	post.UnmarshalJSON(body)

	if post.Message != "" {
		if post.Message != oldPost.Message {
			oldPost.Message = models.UpdatePost(env.db, postId, *post)
			oldPost.IsEdited = true
		}
	}

	// outStr, _ := json.Marshal(oldPost)
	outStr, _ := oldPost.MarshalJSON()
	w.WriteHeader(http.StatusOK)
	w.Write(outStr)
}

func (env *Env) detailsPost(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	postId := vars["id"]

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

		// outStr, _ := json.Marshal(postDetail)
		outStr, _ := postDetail.MarshalJSON()
		w.WriteHeader(http.StatusOK)
		w.Write(outStr)
		return
	}

	msg := map[string]string{"message": "Can't find post by id: " + postId}
	outStr, _ := json.Marshal(msg)
	w.WriteHeader(http.StatusNotFound)
	w.Write(outStr)
}


func (env *Env) getPostsList(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	thread := vars["slug"]

	var has bool
	oldThread := &models.Thread{}
	var msg map[string]string
	var ThreadId string

	if _, err := strconv.Atoi(thread); err == nil {
		oldThread, has = models.GetThreadById(env.db, thread)
		ThreadId = thread
		msg = map[string]string{"message": "Can't find thread by id: " + thread}
	} else {
		oldThread, has = models.GetThreadBySlug(env.db, thread)
		ThreadId = strconv.FormatInt(oldThread.Id, 10)
		msg = map[string]string{"message": "Can't find thread by slug: " + thread}
	}

	if !has {
		outStr, _ := json.Marshal(msg)
		w.WriteHeader(http.StatusNotFound)
		w.Write(outStr)
		return
	}

	limit := r.FormValue("limit")
	since := r.FormValue("since")
	sort := r.FormValue("sort")
	desc := r.FormValue("desc")

	posts, _ := models.GetPostsList(env.db, ThreadId, limit, since, sort, desc)

	outStr, _ := json.Marshal(posts)
	w.WriteHeader(http.StatusOK)
	w.Write(outStr)
}
