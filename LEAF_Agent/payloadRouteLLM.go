package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RouteLLMPayload struct {
	ReadIndicatorIDs []int `json:"readIndicatorIDs"`
}

// routeLLM executes an action based on the LLM's response, using context from data fields
// matching payload.ReadIndicatorIDs.
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

	// Setup LLM prompt
	actions, err := GetActions(task.SiteURL, task.StepID)
	if err != nil {
		return err
	}

	var choices string
	for _, action := range actions {
		choices += "- " + action.ActionText + "\n"
	}
	choices = strings.Trim(choices, "\n")

	indicators, err := GetIndicatorMap(task.SiteURL)
	if err != nil {
		return err
	}

	for recordID, record := range records {
		prompt := message{
			Role:    "system",
			Content: "Categorize the following text. Only respond with one of these categories:\n" + choices,
		}
		context := ""
		for _, indicatorID := range payload.ReadIndicatorIDs {
			context += indicators[indicatorID].Name + ": " + record.S1["id"+strconv.Itoa(indicatorID)] + "\n\n"
		}
		context = strings.Trim(context, "\n")

		input := message{
			Role:    "user",
			Content: context,
		}

		config := completions{
			Model: "gemma-3-4b-it-qat-q4_0",
			Messages: []message{
				prompt, input,
			},
			MaxCompletionTokens: 50,
		}

		llmResponse, err := GetLLMResponse(config)
		if err != nil {
			return fmt.Errorf("LLM: %w", err)
		}

		cleanResponse := strings.Trim(llmResponse.Choices[0].Message.Content, " \n")

		// Restrict output to predefined list
		approvedActionType := ""
		for _, v := range actions {
			if v.ActionText == cleanResponse {
				approvedActionType = v.ActionType
				break
			}
		}

		if approvedActionType != "" {
			TakeAction(task.SiteURL, recordID, task.StepID, approvedActionType, "")
		} else {
			log.Println("LLM invalid output: ", "'"+llmResponse.Choices[0].Message.Content+"'", "TaskID:", task.TaskID, "RecordID:", recordID)
		}
	}

	return nil
}
