package main

import (
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type UpdateDataConditionalPayload struct {
	Query            query.Query `json:"query"`
	WriteIndicatorID int         `json:"writeIndicatorID"`
	Content          string      `json:"content"`
}

// updateDataConditional updates data matching WriteIndicatorID for all records that match payload.Query AND the task's stepID.
func updateDataConditional(task *Task, payload UpdateDataConditionalPayload) {
	// Initialize query. At minimum it should only return records that match the stepID
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    task.StepID,
			},
		},
	}

	// Only use allowed terms in the query
	for _, term := range payload.Query.Terms {
		switch term.ID {
		case "data",
			"serviceID",
			"title",
			"userID",
			"dateInitiated",
			"dateSubmitted",
			"categoryID",
			"dependencyID",
			"stepAction":
			query.Terms = append(query.Terms, term)
		}
	}

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		task.HandleError(0, "updateDataConditional:", err)
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	for recordID := range records {
		// Only process records within the current set
		if _, exists := task.Records[recordID]; !exists {
			continue
		}

		data := map[int]string{}
		data[payload.WriteIndicatorID] = payload.Content
		err = UpdateRecord(task.SiteURL, recordID, data)
		if err != nil {
			task.HandleError(recordID, "updateDataConditional:", err)
		}
	}
}
