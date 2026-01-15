package agent

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
type Completions struct {
	Model               string    `json:"model"`
	Messages            []Message `json:"messages"`
	MaxCompletionTokens int       `json:"max_completion_tokens"`
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type LLMResponse struct {
	Choices []choice `json:"choices"`
	Timings timings  `json:"timings"`
}

type choice struct {
	FinishReason string  `json:"finish_reason"`
	Index        int     `json:"index"`
	Message      Message `json:"message"`
}

type timings struct {
	PromptPerSecond    float64 `json:"prompt_per_second"`
	PredictedPerSecond float64 `json:"predicted_per_second"`
}

func (a Agent) GetLLMResponse(config Completions) (LLMResponse, error) {
	jsonConfig, _ := json.Marshal(config)

	req, err := http.NewRequest("POST", a.llmCategorizationURL, bytes.NewBuffer(jsonConfig))
	if err != nil {
		return LLMResponse{}, fmt.Errorf("GetLLMResponse: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+a.llmApiKey)
	req.Header.Set("Content-Type", "application/json")

	res, err := a.llmHttpClient.Do(req)
	if err != nil {
		return LLMResponse{}, fmt.Errorf("LLM_CATEGORIZATION_URL: %w", err)
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return LLMResponse{}, fmt.Errorf("LLM: Read Err: %w", err)
	}

	if res.StatusCode != 200 {
		return LLMResponse{}, errors.New("LLM Status " + strconv.Itoa(res.StatusCode) + ": " + string(b))
	}

	var llmResponse LLMResponse
	err = json.Unmarshal(b, &llmResponse)
	if err != nil {
		return LLMResponse{}, fmt.Errorf("LLM: %w", err)
	}

	if len(llmResponse.Choices) == 0 {
		return LLMResponse{}, errors.New("LLM Output Error: " + string(b))
	}

	return llmResponse, nil
}
