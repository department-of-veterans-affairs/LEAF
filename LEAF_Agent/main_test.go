package main

import (
	"log"
	"net/http"
	"net/http/cookiejar"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/agent"
)

type testWorker struct {
	client    *http.Client
	clientLLM *http.Client
	agent     *agent.Agent
	config    agent.Completions
}

func newTestWorker() *testWorker {
	worker := &testWorker{}

	var cookieJar, _ = cookiejar.New(nil)
	worker.client = &http.Client{
		Timeout: time.Second * 5,
		Jar:     cookieJar,
	}

	var cookieJarLLM, _ = cookiejar.New(nil)
	worker.clientLLM = &http.Client{
		Timeout: time.Second * 60,
		Jar:     cookieJarLLM,
	}

	worker.agent = agent.New(worker.client, worker.clientLLM)

	prompt := agent.Message{
		Role: "user",
		Content: "Categorize the following text. Only respond with one of these categories:\n" +
			"- Consultation\n" +
			"- Technical Issue\n" +
			"- Idea\n",
	}
	context := "It would be great if this could make coffee"

	input := agent.Message{
		Role:    "user",
		Content: context,
	}

	worker.config = agent.Completions{
		Model: "gemma-3-4b-it-qat-q4_0",
		Messages: []agent.Message{
			prompt, input,
		},
		MaxCompletionTokens: 50,
	}

	return worker
}

func (w *testWorker) run() (agent.LLMResponse, error) {
	return w.agent.GetLLMResponse(w.config)
}

func TestLLMAPIResponse(t *testing.T) {
	worker := newTestWorker()

	start := time.Now()

	llmResponse, err := worker.run()
	if err != nil {
		t.Error(err)
	}

	elapsed := time.Since(start)
	log.Println("LLM response time (single request): ", elapsed)

	if !strings.Contains(llmResponse.Choices[0].Message.Content, "Idea") {
		t.Errorf(`LLM response want = "Idea", got = %v`, llmResponse.Choices[0].Message.Content)
	}
}

func BenchmarkParallelLLM(b *testing.B) {
	var wg sync.WaitGroup
	numWorkers := 10 // should be a bit more than the LLM's parallel setting to check its scheduler
	workers := []*testWorker{}

	for range numWorkers {
		workers = append(workers, newTestWorker())
	}

	for b.Loop() {
		for _, w := range workers {
			wg.Go(func() {
				_, err := w.run()
				if err != nil {
					b.Error(err)
				}
			})
		}

		wg.Wait()
	}
}
