package agent

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"

	"github.com/microcosm-cc/bluemonday"
)

type UpdateData4BLLMPayload struct {
	Context          string `json:"context"`
	ReadIndicatorIDs []int  `json:"readIndicatorIDs"`
	WriteIndicatorID int    `json:"writeIndicatorID"`
}

// updateData4bLLM updates a record's data field (payload.WriteIndicatorID) based on Context and content
// from ReadIndicatorIDs using a ~4B parameter LLM.
// WriteIndicatorID must reference a text or textarea field
func (a Agent) updateData4BLLM(task *Task, payload UpdateData4BLLMPayload) {
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
		task.HandleError(0, "updateData4BLLM:", err)
		return
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	indicators, err := a.GetIndicatorMap(task.SiteURL)
	if err != nil {
		task.HandleError(0, "updateData4BLLM:", err)
		return
	}

	if indicators[payload.WriteIndicatorID].Format != "text" && indicators[payload.WriteIndicatorID].Format != "textarea" {
		task.HandleError(0, "updateData4BLLM:", fmt.Errorf("indicator ID %d does not reference a text or textarea field", payload.WriteIndicatorID))
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
			Content: payload.Context,
		}
		context := ""
		for _, indicatorID := range payload.ReadIndicatorIDs {
			iiD := strconv.Itoa(indicatorID)
			if strings.TrimSpace(record.S1["id"+iiD]) != "" {
				context += indicators[indicatorID].Name + ": " + record.S1["id"+iiD] + "\n\n"
			}
		}
		context = strings.TrimSpace(context)

		input := Message{
			Role:    "user",
			Content: context,
		}

		config := Completions{
			Model: "gemma-3-4b-it-qat-q4_0",
			Messages: []Message{
				prompt, input,
			},
		}

		llmResponse, err := a.GetLLMResponse(config)
		if err != nil {
			task.HandleError(0, "updateData4BLLM:", fmt.Errorf("GetLLMResponse: %w", err))
			return
		}

		scrubber := bluemonday.StrictPolicy()
		cleanResponse := scrubber.Sanitize(llmResponse.Choices[0].Message.Content)

		data := map[int]string{}
		data[payload.WriteIndicatorID] = cleanResponse
		err = a.UpdateRecord(task.SiteURL, recordID, data)
		if err != nil {
			task.HandleError(0, "updateData4BLLM:", err)
		}

	}
}
