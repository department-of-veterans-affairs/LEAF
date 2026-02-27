package agent

import (
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"os"
	"testing"
	"time"
)

var agent Agent

func TestMain(m *testing.M) {
	log.SetOutput(io.Discard) // avoid spamming test output?

	var cookieJar, _ = cookiejar.New(nil)

	agent = Agent{
		authToken: os.Getenv("AGENT_TOKEN"),
		httpHost:  os.Getenv("HTTP_HOST"),
		httpClient: &http.Client{
			Timeout: time.Second * 5,
			Jar:     cookieJar,
		},
		llmHttpClient: &http.Client{
			Timeout: time.Second * 30,
			Jar:     cookieJar,
		},
		llmApiKey: os.Getenv("LLM_API_KEY"),
	}

	m.Run()
}
