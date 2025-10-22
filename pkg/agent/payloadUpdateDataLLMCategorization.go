package agent

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type UpdateDataLLMCategorizationPayload struct {
	ReadIndicatorIDs []int  `json:"readIndicatorIDs"`
	WriteIndicatorID int    `json:"writeIndicatorID"`
	Context          string `json:"context,omitempty"`
}

// updateDataLLMCategorization updates a record's data field (payload.WriteIndicatorID).
// The data field's format must support single-select multiple-options.
// The LLM will categorize content based on available options for the data field using context
// provided by data fields matching payload.ReadIndicatorIDs.
func (a Agent) updateDataLLMCategorization(task *Task, payload UpdateDataLLMCategorizationPayload) {
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
		task.HandleError(0, "updateDataLLMCategorization:", err)
		return
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	indicators, err := a.GetIndicatorMap(task.SiteURL)
	if err != nil {
		task.HandleError(0, "updateDataLLMCategorization:", err)
		return
	}

	if len(indicators[payload.WriteIndicatorID].FormatOptions) == 0 {
		task.HandleError(0, "updateDataLLMCategorization:", fmt.Errorf("indicator ID %d does not have any options", payload.WriteIndicatorID))
		return
	}

	// Prep the list of categories for the LLM's prompt
	var categories string
	for _, category := range indicators[payload.WriteIndicatorID].FormatOptions {
		if strings.Trim(category, " ") != "" {
			categories += "- " + category + "\n"
		}
	}
	categories = strings.Trim(categories, "\n")

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
			Content: payload.Context + "Categorize the following text. Only respond with one of these categories:\n" + categories,
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

		llmResponse, err := a.GetLLMResponse(config)
		if err != nil {
			task.HandleError(0, "updateDataLLMCategorization:", fmt.Errorf("GetLLMResponse: %w", err))
			return
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
			err = a.UpdateRecord(task.SiteURL, recordID, data)
			if err != nil {
				task.HandleError(0, "updateDataLLMCategorization:", err)
			}
		} else {
			task.HandleError(recordID, "updateDataLLMCategorization:", fmt.Errorf("LLM invalid output: '%v' TaskID: %v RecordID: %v", llmResponse.Choices[0].Message.Content, task.TaskID, recordID))
		}
	}
}
