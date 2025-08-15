package main

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"

	"github.com/microcosm-cc/bluemonday"
)

type UpdateDataLLMLabelPayload struct {
	ReadIndicatorIDs []int  `json:"readIndicatorIDs"`
	WriteIndicatorID int    `json:"writeIndicatorID"`
	Context          string `json:"context,omitempty"`
}

// updateDataLLMLabel updates a record's data field (payload.WriteIndicatorID) with
// a short < 50 character label for the data within ReadIndicatorIDs.
// WriteIndicatorID must reference a text or textarea field
func updateDataLLMLabel(task *Task, payload UpdateDataLLMLabelPayload) {
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
		task.HandleError(0, "updateDataLLMLabel:", err)
		return
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	indicators, err := GetIndicatorMap(task.SiteURL)
	if err != nil {
		task.HandleError(0, "updateDataLLMLabel:", err)
		return
	}

	if indicators[payload.WriteIndicatorID].Format != "text" && indicators[payload.WriteIndicatorID].Format != "textarea" {
		task.HandleError(0, "updateDataLLMLabel:", fmt.Errorf("Indicator ID %d does not reference a text or textarea field", payload.WriteIndicatorID))
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

		// Get response from LLM
		prompt := message{
			Role:    "user",
			Content: payload.Context + "Label the following text. The label must be less than 50 characters.",
		}
		context := ""
		inputLength := 0
		for _, indicatorID := range payload.ReadIndicatorIDs {
			iiD := strconv.Itoa(indicatorID)
			if strings.TrimSpace(record.S1["id"+iiD]) != "" {
				context += indicators[indicatorID].Name + ": " + record.S1["id"+iiD] + "\n\n"
				inputLength += len(record.S1["id"+iiD])
			}
		}
		context = strings.TrimSpace(context)

		// Skip record if input is empty
		if inputLength == 0 {
			continue
		}

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
			task.HandleError(0, "updateDataLLMLabel:", fmt.Errorf("GetLLMResponse: %w", err))
			return
		}

		cleanResponse := strings.Trim(llmResponse.Choices[0].Message.Content, " \n.")
		scrubber := bluemonday.StrictPolicy()
		cleanResponse = scrubber.Sanitize(cleanResponse)

		if len(llmResponse.Choices[0].Message.Content) > 50 {
			task.HandleError(recordID, "updateDataLLMLabel:", fmt.Errorf("LLM response exceeds 50 character constraint: %v", cleanResponse))
			return
		}

		data := map[int]string{}
		data[payload.WriteIndicatorID] = cleanResponse
		err = UpdateRecord(task.SiteURL, recordID, data)
		if err != nil {
			task.HandleError(0, "updateDataLLMLabel:", err)
		}

	}
}
