package agent

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"

	"github.com/microcosm-cc/bluemonday"
)

type UpdateTitleLLMLabelPayload struct {
	ReadIndicatorIDs []int  `json:"readIndicatorIDs"`
	Context          string `json:"context,omitempty"`
}

// updateTitleLLMLabel updates a record's title with a short < 50 character
// label for the data within ReadIndicatorIDs.
func (a Agent) updateTitleLLMLabel(task *Task, payload UpdateTitleLLMLabelPayload) {
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

	records, err := a.FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		task.HandleError(0, "updateTitleLLMLabel:", err)
		return
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	indicators, err := a.GetIndicatorMap(task.SiteURL)
	if err != nil {
		task.HandleError(0, "updateTitleLLMLabel:", err)
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
		prompt := Message{
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

		input := Message{
			Role:    "user",
			Content: context,
		}

		config := Completions{
			Model: "gemma-3-4b-it-qat-q4_0",
			Messages: []Message{
				prompt, input,
			},
			MaxCompletionTokens: 50,
		}

		llmResponse, err := a.GetLLMResponse(config)
		if err != nil {
			task.HandleError(0, "updateTitleLLMLabel:", fmt.Errorf("GetLLMResponse: %w", err))
			return
		}

		cleanResponse := strings.Trim(llmResponse.Choices[0].Message.Content, " \n.")
		scrubber := bluemonday.StrictPolicy()
		cleanResponse = scrubber.Sanitize(cleanResponse)

		if len(llmResponse.Choices[0].Message.Content) > 50 {
			task.HandleError(recordID, "updateTitleLLMLabel:", fmt.Errorf("LLM response exceeds 50 character constraint: %v", cleanResponse))
			return
		}

		err = a.UpdateTitle(task.SiteURL, recordID, cleanResponse)
		if err != nil {
			task.HandleError(0, "updateTitleLLMLabel:", err)
		}

	}
}
