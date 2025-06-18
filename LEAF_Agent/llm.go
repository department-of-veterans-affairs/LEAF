package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"
)

// Completions is the structure of the response from llama.cpp's Open-AI compatible Completions API
// API overview: https://github.com/ggml-org/llama.cpp/tree/master/tools/server
type completions struct {
	Model               string    `json:"model"`
	Messages            []message `json:"messages"`
	MaxCompletionTokens int       `json:"max_completion_tokens"`
}

type message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type response struct {
	Choices []choice `json:"choices"`
	Timings timings  `json:"timings"`
}

type choice struct {
	FinishReason string  `json:"finish_reason"`
	Index        int     `json:"index"`
	Message      message `json:"message"`
}

type timings struct {
	PromptPerSecond    float64 `json:"prompt_per_second"`
	PredictedPerSecond float64 `json:"predicted_per_second"`
}

func GetLLMResponse(config completions) (response, error) {
	jsonConfig, _ := json.Marshal(config)

	req, err := http.NewRequest("POST", APP_AGENT_LLM_URL_CATEGORIZATION, bytes.NewBuffer(jsonConfig))
	if err != nil {
		return response{}, fmt.Errorf("LLM: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+LLM_API_KEY)
	req.Header.Set("Content-Type", "application/json")

	res, err := clientLLM.Do(req)
	if err != nil {
		return response{}, fmt.Errorf("LLM: %w", err)
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return response{}, fmt.Errorf("LLM: Read Err: %w", err)
	}

	if res.StatusCode != 200 {
		return response{}, errors.New("LLM Status " + strconv.Itoa(res.StatusCode) + ": " + string(b))
	}

	var llmResponse response
	err = json.Unmarshal(b, &llmResponse)
	if err != nil {
		return response{}, fmt.Errorf("LLM: %w", err)
	}

	if len(llmResponse.Choices) == 0 {
		return response{}, errors.New("LLM Output Error: " + string(b))
	}

	return llmResponse, nil
}
