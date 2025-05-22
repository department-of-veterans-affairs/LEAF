package main

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
