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

type RouteLLMPayload struct {
	Actions          []action `json:"actions"`
	ReadIndicatorIDs []int    `json:"readIndicatorID"`
}

type action struct {
	ActionType  string `json:"actionType"`
	Description string `json:"description"`
}

func routeLLM(task Task, payload RouteLLMPayload) error {
	// Initialize query. At minimum it should only return records that match the stepID
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    task.StepID,
			},
		},
		GetData: payload.ReadIndicatorIDs,
	}

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		return err
	}

	var actions string
	for _, action := range payload.Actions {
		description := ""
		if action.Description != "" {
			description = " (e.g. " + action.Description + ")"
		}
		actions += "- " + action.ActionType + description + "\n"
	}
	actions = strings.Trim(actions, "\n")

	for recordID, record := range records {
		// Get response from LLM
		prompt := message{
			Role:    "system",
			Content: "Categorize the following text. Only respond with one of these categories:\n" + actions,
		}
		context := ""
		for _, indicatorID := range payload.ReadIndicatorIDs {
			context += record.S1["id"+strconv.Itoa(indicatorID)] + "\n\n"
		}
		context = strings.Trim(context, "\n")

		input := message{
			Role:    "user",
			Content: record.S1["id"+context],
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

		res, err := clientLLM.Do(req)
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

		cleanResponse := strings.Trim(llmResponse.Choices[0].Message.Content, " \n")

		// Restrict output to predefined list
		hasApprovedOutput := false
		for i := range payload.Actions {
			if payload.Actions[i].ActionType == cleanResponse {
				hasApprovedOutput = true
				break
			}
		}

		if hasApprovedOutput {
			TakeAction(task.SiteURL, recordID, task.StepID, cleanResponse, "")
		} else {
			log.Println("LLM invalid output: ", "'"+llmResponse.Choices[0].Message.Content+"'", "TaskID:", task.TaskID, "RecordID:", recordID)
		}
	}

	return nil
}
