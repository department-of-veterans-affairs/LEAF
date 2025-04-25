package main

import (
	"crypto/tls"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"
)

func main() {
	log.Println("Starting LEAF Agent...")
	http.HandleFunc("/", handleIndex)
	http.HandleFunc("/api/v1/test", handleRunTest)

	http.ListenAndServe(":8000", nil)
}

func handleIndex(w http.ResponseWriter, r *http.Request) {
	out := "This is the LEAF Agent"
	log.Println("Sent:", out)
	io.WriteString(w, out)
}

var runningTests = false
var mxRunningTests sync.Mutex

func handleRunTest(w http.ResponseWriter, r *http.Request) {
	mxRunningTests.Lock()
	if !runningTests {
		runningTests = true
		log.Println("Starting a test run")

		var tr = &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		}

		var cookieJar, _ = cookiejar.New(nil)
		var client = &http.Client{
			Transport: tr,
			Timeout:   time.Second * 5,
			Jar:       cookieJar,
		}

		data := url.Values{}
		data.Set("numform_5ea07", "1")
		data.Set("title", "leaf-agent")

		req, err := http.NewRequest("POST", `https://host.docker.internal/Test_Request_Portal/api/form/new`, strings.NewReader(data.Encode()))
		if err != nil {
			log.Println(err)
		}

		req.Header.Set("Authorization", os.Getenv("AGENT_TOKEN"))
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

		res, _ := client.Do(req)
		bodyBytes, _ := io.ReadAll(res.Body)
		log.Println(string(bodyBytes))

		runningTests = false
		mxRunningTests.Unlock()
		log.Println("Completed test run")
	} else {
		io.WriteString(w, "Already running tests")
	}
}
