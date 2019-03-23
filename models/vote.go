package models

import (
	"database/sql"
)

type Vote struct {
	Nickname string `json:"nickname"`
	Voice    int32  `json:"voice"`
	Thread   int64  `json:"thread"`
}

func CreateVote(db *sql.DB, vote *Vote) (error, int32) {
	// _, err := db.Exec("INSERT INTO votes (user_nickname, voice, thread) VALUES ($1, $2, $3)", vote.Nickname, vote.Voice, vote.Thread)
	var voteSum int32
	err := db.QueryRow("SELECT votes from threads WHERE threads.id = $1 ", vote.Thread).Scan(&voteSum)

	var lastVoice int32
	err = db.QueryRow("SELECT voice from votes WHERE votes.thread = $1 AND votes.user_nickname = $2",
		vote.Thread, vote.Nickname).Scan(&lastVoice)

	if err == nil {
		if lastVoice == vote.Voice {
			return nil, voteSum
		}

		if vote.Voice == -1 {
			_, err = db.Exec("UPDATE threads SET votes = votes - 2 WHERE threads.id = $1", vote.Thread)
			_, err = db.Exec("UPDATE votes SET voice = -1 WHERE votes.thread = $1 AND votes.user_nickname = $2",
				vote.Thread, vote.Nickname)
			return err, voteSum + 2*vote.Voice
		} else {
			_, err = db.Exec("UPDATE threads SET votes = votes + 2 WHERE threads.id = $1", vote.Thread)
			_, err = db.Exec("UPDATE votes SET voice = 1 WHERE votes.thread = $1 AND votes.user_nickname = $2",
				vote.Thread, vote.Nickname)
			return err, voteSum + 2*vote.Voice
		}
	}

	// Если голоса не было
	_, err = db.Exec("INSERT INTO votes (user_nickname, voice, thread) VALUES ($1, $2, $3)",
		vote.Nickname, vote.Voice, vote.Thread)
	_, err = db.Exec("UPDATE threads SET votes = votes + $1 WHERE threads.id = $2", vote.Voice, vote.Thread)
	return err, voteSum + vote.Voice

	// if vote.Voice == -1 {
	// 	_, err = db.Exec("INSERT INTO votes (user_nickname, voice, thread) VALUES ($1, $2, $3)",
	// 		vote.Nickname, vote.Voice, vote.Thread)
	// 	return err, lastVoice - vote.Voice
	// } else {
	// 	_, err = db.Exec("UPDATE threads SET votes = votes + 1 WHERE threads.id = $1", vote.Thread)
	// 	return err, lastVoice + vote.Voice
	// }

}
