package main

import (
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RoutePayload struct {
	ActionType string `json:"actionType"`
	Comment    string `json:"comment,omitempty"`
}

// route executes an action, payload.ActionType, for all records matching the task
func route(task Task, payload RoutePayload) error {
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

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		return err
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return nil
	}

	for recordID := range records {
		err = TakeAction(task.SiteURL, recordID, task.StepID, payload.ActionType, payload.Comment)
		if err != nil {
			return err
		}
	}

	return nil
}
