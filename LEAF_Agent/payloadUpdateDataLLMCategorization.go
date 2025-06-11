package main

import (
	"fmt"
	"log"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type UpdateDataLLMCategorizationPayload struct {
	ReadIndicatorIDs []int `json:"readIndicatorIDs"`
	WriteIndicatorID int   `json:"writeIndicatorID"`
}

// updateDataLLMCategorization updates a record's data field (payload.WriteIndicatorID).
// The data field's format must support single-select multiple-options.
// The LLM will categorize content based on available options for the data field using context
// provided by data fields matching payload.ReadIndicatorIDs.
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
		GetData: payload.ReadIndicatorIDs,
	}

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		return err
	}

	indicators, err := GetIndicatorMap(task.SiteURL)
	if err != nil {
		return err
	}

	if len(indicators[payload.WriteIndicatorID].FormatOptions) == 0 {
		return fmt.Errorf("Indicator ID %d does not have any options", payload.WriteIndicatorID)
	}

	// Prep the list of categories for the LLM's prompt
	var categories string
	for _, category := range indicators[payload.WriteIndicatorID].FormatOptions {
		categories += "- " + category + "\n"
	}
	categories = strings.Trim(categories, "\n")

	for recordID, record := range records {
		// Get response from LLM
		prompt := message{
			Role:    "system",
			Content: "Categorize the following text. Only respond with one of these categories:\n" + categories,
		}
		context := ""
		for _, indicatorID := range payload.ReadIndicatorIDs {
			context += indicators[indicatorID].Name + ": " + record.S1["id"+strconv.Itoa(indicatorID)] + "\n"
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
			log.Println("LLM: ", err)
		}

		cleanResponse := strings.Trim(llmResponse.Choices[0].Message.Content, " \n")

		// Restrict output to predefined list
		hasApprovedOutput := false
		for i := range indicators[payload.WriteIndicatorID].FormatOptions {
			if indicators[payload.WriteIndicatorID].FormatOptions[i] == cleanResponse {
				hasApprovedOutput = true
				break
			}
		}

		if hasApprovedOutput {
			data := map[int]string{}
			data[payload.WriteIndicatorID] = cleanResponse
			err = UpdateRecord(task.SiteURL, recordID, data)
			if err != nil {
				return err
			}
		} else {
			return fmt.Errorf("LLM invalid output: '%v' TaskID: %v RecordID: %v", llmResponse.Choices[0].Message.Content, task.TaskID, recordID)
		}
	}

	return nil
}
