package main

import (
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"testing"
	"time"
)

func TestMain(m *testing.M) {
	log.SetOutput(io.Discard) // avoid spamming test output?

	var cookieJar, _ = cookiejar.New(nil)
	client = &http.Client{
		Timeout: time.Second * 5,
		Jar:     cookieJar,
	}

	clientLLM = &http.Client{
		Timeout: time.Second * 5,
		Jar:     cookieJar,
	}

	m.Run()
}
