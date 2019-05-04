package models

import (
	"github.com/jackc/pgx"
	// "database/sql"
)

type Vote struct {
	Nickname string `json:"nickname"`
	Voice    int32  `json:"voice"`
	Thread   int64  `json:"thread"`
}


func CreateVote(db *pgx.ConnPool , vote *Vote) (error, int32) {
	var voteSum int32

	/*
		USED TRIGGER TO UPDATE FIELD threads.votes
					JUST FOR FUN

	CREATE TRIGGER thread_votes_incr
		AFTER INSERT ON votes
		FOR EACH ROW
		EXECUTE PROCEDURE incr_votes_count();
	CREATE TRIGGER thread_votes_decr
		AFTER DELETE ON votes
		FOR EACH ROW
		EXECUTE PROCEDURE decr_votes_count();
	CREATE OR REPLACE FUNCTION incr_votes_count() RETURNS TRIGGER AS $example_table$
	BEGIN
		UPDATE threads
		SET votes = votes + NEW.voice
		WHERE id = NEW.thread;
		RETURN NEW;
	END;
	$example_table$ LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION decr_votes_count() RETURNS TRIGGER AS $example_table$
	BEGIN
		UPDATE threads
		SET votes = votes - OLD.voice
		WHERE id = OLD.thread;
		RETURN OLD;
	END;
	$example_table$ LANGUAGE plpgsql;
	*/

	tx, err := db.Begin()
	if err != nil {
		// log.Println(err)
		return err, 0
	}

	_, err = tx.Exec(`DELETE FROM votes
					  WHERE user_nickname = $1 AND thread = $2`, 
				vote.Nickname, vote.Thread)

	_, err = tx.Exec(`INSERT INTO votes (user_nickname, voice, thread)
					  VALUES 
					        ($1, $2, $3)`, 
				vote.Nickname, vote.Voice, vote.Thread)
					   
	err = tx.QueryRow(`SELECT votes
					   FROM threads 
					   WHERE id = $1`, 
					   vote.Thread).Scan(&voteSum)
					   
	if err != nil {
		// log.Println(err)
		tx.Rollback()
		return err, 0
	}
	
	tx.Commit()
	// _, err := db.Exec("DELETE FROM votes WHERE user_nickname = $1 AND thread = $2",
	// 	vote.Nickname, vote.Thread)
	// _ = err
	// _, err = db.Exec("INSERT INTO votes (user_nickname, voice, thread) VALUES ($1, $2, $3)",
	// 	vote.Nickname, vote.Voice, vote.Thread)
	// err = db.QueryRow("SELECT votes FROM threads WHERE id = $1", vote.Thread).Scan(&voteSum)

	// err := db.QueryRow(query, vote.Nickname, vote.Thread).Scan(&voteSum)

	return err, voteSum
}
