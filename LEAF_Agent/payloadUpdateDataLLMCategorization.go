package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type UpdateDataLLMCategorizationPayload struct {
	Categories       []category `json:"categories"`
	ReadIndicatorID  int        `json:"readIndicatorID"`
	WriteIndicatorID int        `json:"writeIndicatorID"`
}

type category struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func updateDataLLMCategorization(task Task, payload UpdateDataLLMCategorizationPayload) error {
	// Initialize query. At minimum it should only return records that match the stepID
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    task.StepID,
			},
		},
		GetData: []int{payload.ReadIndicatorID},
	}

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		return err
	}

	var categories string
	for _, category := range payload.Categories {
		description := ""
		if category.Description != "" {
			description = " (e.g. " + category.Description + ")"
		}
		categories += "- " + category.Name + description + "\n"
	}
	categories = strings.Trim(categories, "\n")

	for recordID, record := range records {
		// Get response from LLM
		prompt := message{
			Role:    "system",
			Content: "Categorize the following text. Only respond with one of these categories:\n" + categories,
		}
		input := message{
			Role:    "user",
			Content: record.S1["id"+strconv.Itoa(payload.ReadIndicatorID)],
		}

		config := completions{
			Model: "gemma-3-4b-it-qat-q4_0",
			Messages: []message{
				prompt, input,
			},
			MaxCompletionTokens: 50,
		}

		jsonConfig, _ := json.Marshal(config)

		req, err := http.NewRequest("POST", APP_AGENT_LLM_URL_CATEGORIZATION, bytes.NewBuffer(jsonConfig))
		if err != nil {
			log.Println("LLM: ", err)
		}

		req.Header.Set("Authorization", "Bearer "+AGENT_LLM_TOKEN)
		req.Header.Set("Content-Type", "application/json")

		res, err := client.Do(req)
		if err != nil {
			log.Println("LLM: ", err)
		}

		b, _ := io.ReadAll(res.Body)

		var llmResponse response
		err = json.Unmarshal(b, &llmResponse)
		if err != nil {
			log.Println("LLM: ", err)
		}

		if len(llmResponse.Choices) == 0 {
			return errors.New("LLM Output Error: " + string(b))
		}

		cleanResponse := strings.Trim(llmResponse.Choices[0].Message.Content, "\n")

		hasApprovedOutput := false
		for i := range payload.Categories {
			if payload.Categories[i].Name == cleanResponse {
				hasApprovedOutput = true
				break
			}
		}

		if hasApprovedOutput {
			data := map[int]string{}
			data[payload.WriteIndicatorID] = cleanResponse
			UpdateRecord(task.SiteURL, recordID, data)
		} else {
			log.Println("LLM invalid output: ", "'"+llmResponse.Choices[0].Message.Content+"'", "TaskID:", task.TaskID, "RecordID:", recordID)
		}
	}

	return nil
}

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
