package main

import (
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RouteConditionalDataPayload struct {
	ActionType string      `json:"actionType"`
	Query      query.Query `json:"query"`
	Comment    string      `json:"comment,omitempty"`
}

// routeConditionalData executes an action, payload.ActionType, for all records that match payload.Query AND the task's stepID.
func routeConditionalData(task Task, payload RouteConditionalDataPayload) error {
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
