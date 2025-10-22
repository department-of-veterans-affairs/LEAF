package main

import (
	"log"
	"net/http"
	"net/http/cookiejar"
	"strings"
	"testing"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/agent"
)

func TestLLMAPIResponse(t *testing.T) {
	var cookieJar, _ = cookiejar.New(nil)
	client := &http.Client{
		Timeout: time.Second * 5,
		Jar:     cookieJar,
	}

	var cookieJarLLM, _ = cookiejar.New(nil)
	clientLLM := &http.Client{
		Timeout: time.Second * 60,
		Jar:     cookieJarLLM,
	}

	leafAgent := agent.New(client, clientLLM)

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

	config := agent.Completions{
		Model: "gemma-3-4b-it-qat-q4_0",
		Messages: []agent.Message{
			prompt, input,
		},
		MaxCompletionTokens: 50,
	}

	start := time.Now()

	llmResponse, err := leafAgent.GetLLMResponse(config)
	if err != nil {
		t.Error(err)
	}

	elapsed := time.Since(start)
	log.Println("LLM response time: ", elapsed)

	if !strings.Contains(llmResponse.Choices[0].Message.Content, "Idea") {
		t.Errorf(`LLM response want = "Idea", got = %v`, llmResponse.Choices[0].Message.Content)
	}
}
