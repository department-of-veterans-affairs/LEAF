package main

import (
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RouteLLMPayload struct {
	ReadIndicatorIDs []int  `json:"readIndicatorIDs"`
	Context          string `json:"context"`
}

// routeLLM executes an action based on the LLM's response, using context from data fields
// matching payload.ReadIndicatorIDs. The available actions are automatically retrieved during runtime.
// To help enforce human decision-making responsibilities, the LLM is not allowed to apply
// approve/disapprove/deny actions.
func routeLLM(task *Task, payload RouteLLMPayload) {
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
		task.HandleError(0, "routeLLM:", err)
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	// Setup LLM prompt
	actions, err := GetActions(task.SiteURL, task.StepID)
	if err != nil {
		task.HandleError(0, "routeLLM:", err)
		return
	}

	var choices string
	for _, action := range actions {
		choices += "- " + action.ActionText + "\n"

		// Do not allow approve/disapprove/deny actions
		if action.ActionType == "approve" || action.ActionType == "disapprove" || action.ActionType == "deny" {
			task.HandleError(0, "routeLLM:", errors.New("LLM routing does not support approve/disapprove/deny actions"))
			return
		}
	}
	choices = strings.Trim(choices, "\n")

	indicators, err := GetIndicatorMap(task.SiteURL)
	if err != nil {
		task.HandleError(0, "routeLLM:", err)
		return
	}

	payload.Context = strings.TrimSpace(payload.Context)
	if payload.Context != "" {
		payload.Context += "\n"
	}

	for recordID, record := range records {
		// Only process records within the current set
		if _, exists := task.Records[recordID]; !exists {
			continue
		}

		prompt := message{
			Role:    "system",
			Content: payload.Context + "Categorize the following text. Only respond with one of these categories:\n" + choices,
		}
		context := ""
		for _, indicatorID := range payload.ReadIndicatorIDs {
			iiD := strconv.Itoa(indicatorID)
			if strings.TrimSpace(record.S1["id"+iiD]) != "" {
				context += indicators[indicatorID].Name + ": " + record.S1["id"+iiD] + "\n\n"
			}
		}
		context = strings.TrimSpace(context)

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
			task.HandleError(0, "routeLLM:", err)
			return
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
			err = TakeAction(task.SiteURL, recordID, task.StepID, approvedActionType, "")
			if err != nil {
				task.HandleError(recordID, "routeLLM:", err)
			}
		} else {
			task.HandleError(recordID, "routeLLM:", fmt.Errorf("LLM invalid output: '%v' TaskID: %v RecordID: %v", llmResponse.Choices[0].Message.Content, task.TaskID, recordID))
		}
	}
}
