package main

import (
	"crypto/tls"
	"log"
	"net/http"
	"net/http/cookiejar"
	"os"
	"time"
)

var client *http.Client
var AGENT_TOKEN = os.Getenv("AGENT_TOKEN")
var HTTP_HOST = os.Getenv("APP_HTTP_HOST")

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	var tr = &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}

	var cookieJar, _ = cookiejar.New(nil)
	client = &http.Client{
		Transport: tr,
		Timeout:   time.Second * 5,
		Jar:       cookieJar,
	}

	log.Println("Starting LEAF Agent Coordinator...")

	for {
		err := UpdateTasks()
		if err != nil {
			log.Println("Error updating tasks:", err)
		}

		tasks, err := FindTasks()
		if err != nil {
			log.Println("Error finding tasks:", err)
		}

		for _, task := range tasks {
			ExecuteTask(task)
		}

		time.Sleep(10 * time.Second)
	}
}
