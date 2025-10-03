package main

import (
	"net/http"
	"net/http/cookiejar"
	"testing"
	"time"
)

func TestMain(m *testing.M) {
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
