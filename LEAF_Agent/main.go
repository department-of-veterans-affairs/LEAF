package main

import (
	"crypto/tls"
	"log"
	"net/http"
	"net/http/cookiejar"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var client *http.Client
var clientLLM *http.Client
var AGENT_TOKEN = os.Getenv("AGENT_TOKEN")
var HTTP_HOST = os.Getenv("APP_HTTP_HOST")
var AGENT_LLM_TOKEN = os.Getenv("AGENT_LLM_TOKEN")
var APP_AGENT_LLM_URL_CATEGORIZATION = os.Getenv("APP_AGENT_LLM_URL_CATEGORIZATION")

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

	var cookieJarLLM, _ = cookiejar.New(nil)
	clientLLM = &http.Client{
		Transport: tr,
		Timeout:   time.Second * 60,
		Jar:       cookieJarLLM,
	}

	log.Println("Starting LEAF Agent Coordinator...")

	// Setup graceful shutdown
	exit := make(chan os.Signal, 1)
	closeTicker := make(chan bool)
	signal.Notify(exit, os.Interrupt, syscall.SIGTERM)

	burstLimiter := make(chan time.Time, 10)
	go func() {
		ticker := time.NewTicker(time.Second / 10) // 10 tasks per second
		defer ticker.Stop()
		for t := range ticker.C {
			burstLimiter <- t
		}
	}()

	// Main loop
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
			select {
			case <-burstLimiter:
				go ExecuteTask(task)
			case <-exit:
				log.Println("Exit signal received, shutting down gracefully...")
				closeTicker <- true

				time.Sleep(5 * time.Second)
				// TODO: Wait for tasks to complete (graceful shutdown)

				return
			}
		}

		time.Sleep(10 * time.Second)
	}
}
