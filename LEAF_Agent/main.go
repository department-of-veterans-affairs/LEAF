package main

import (
	"context"
	"crypto/tls"
	"log"
	"net/http"
	"net/http/cookiejar"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

var client *http.Client
var clientLLM *http.Client
var AGENT_TOKEN = os.Getenv("AGENT_TOKEN")
var HTTP_HOST = os.Getenv("APP_HTTP_HOST")
var LLM_API_KEY = os.Getenv("LLM_API_KEY")
var LLM_CATEGORIZATION_URL = os.Getenv("LLM_CATEGORIZATION_URL")
var wg sync.WaitGroup

func Runner(ctx context.Context, task chan Task) {
	for {
		select {
		case t := <-task:
			ExecuteTask(t)
		case <-ctx.Done():
			return
		}

	}
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	var tr = &http.Transport{}

	// TODO: better way to deal with dev env compatibility?
	if HTTP_HOST != "leaf.va.gov" {
		tr.TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
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
	ctxExit, cancel := context.WithCancel(context.Background())
	exit := make(chan os.Signal, 1)
	signal.Notify(exit, os.Interrupt, syscall.SIGTERM)

	taskChan := make(chan Task)
	for range 10 {
		go Runner(ctxExit, taskChan)
	}

	go func() {
		<-exit
		log.Println("Attempting to gracefully shutdown due to termination signal")
		cancel()
	}()

	var startTime time.Time
	var loopDuration int

	// Main loop
	for {
		startTime = time.Now()

		// Capture exit signal
		select {
		case <-ctxExit.Done():
			return
		default:
		}

		err := UpdateTasks()
		if err != nil {
			log.Println("Error updating tasks:", err)
		}

		tasks, err := FindTasks()
		if err != nil {
			log.Println("Error finding tasks:", err)
		}

		for _, task := range tasks {
			wg.Add(1)
			taskChan <- task

			select {
			case <-ctxExit.Done():
				log.Println("Waiting for in-progress tasks to complete...")
				wg.Wait()
				return
			default:
			}
		}

		wg.Wait()

		// Each loop should be completed within 5 minutes to ensure acceptable quality of service
		loopDuration = int(time.Since(startTime).Seconds())

		// Minimum cooldown, provides potential opportunity to undo actions for endusers
		if loopDuration < 10 {
			cooldown := 10 - loopDuration
			time.Sleep(time.Duration(cooldown) * time.Second)
		}

		log.Println("Tasks completed in", loopDuration, "seconds")
		if loopDuration > 300 {
			log.Println("WARNING: Task completion time exceeds limit. Compute resources should be increased to ensure acceptable quality of service.")
		}
	}
}
