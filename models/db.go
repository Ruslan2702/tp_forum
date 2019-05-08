package models

import (
	"log"
	"github.com/jackc/pgx"
)

func NewPool(host string, port uint16, user, password, database string, maxConn int) *pgx.ConnPool {
	pool, err := pgx.NewConnPool(pgx.ConnPoolConfig{
		ConnConfig: pgx.ConnConfig{
			Host:     host,
			Port:     port,
			User:     user,
			Password: password,
			Database: database,
		},
		MaxConnections: maxConn,
	})

	if err != nil {
		log.Fatal(err)
	}

	return pool
}
