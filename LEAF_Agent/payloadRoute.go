package main

import (
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RoutePayload struct {
	ActionType string `json:"actionType"`
	Comment    string `json:"comment"`
}

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

	for recordID := range records {
		TakeAction(task.SiteURL, recordID, task.StepID, payload.ActionType, payload.Comment)
	}

	return nil
}
