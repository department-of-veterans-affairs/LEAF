package main

import (
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RouteActionHistoryTallyPayload struct {
	ActionType      string `json:"actionType"`
	Comment         string `json:"comment,omitempty"`
	StepID          int    `json:"stepID"`
	ActionTypeTaken string `json:"actionTypeTaken"`
	MinimumCount    int    `json:"minimumCount"`
}

// routeActionHistoryTally executes an action, payload.ActionType, based on a tally of actions taken
// for records matching payload.StepID and where the count of actions is greater than or equal to payload.MinimumCount
func routeActionHistoryTally(task *Task, payload RouteActionHistoryTallyPayload) {
	// Initialize query. At minimum it should only return records that match the stepID
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    task.StepID,
			},
		},
		Joins: []string{"action_history"},
	}

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=action_history.stepID,action_history.actionType")
	if err != nil {
		task.HandleError(0, "routeActionHistoryTally:", err)
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	for recordID, record := range records {
		// Only process records within the current set
		if _, exists := task.Records[recordID]; !exists {
			continue
		}

		actionCount := 0
		for _, action := range record.ActionHistory {
			if action.ActionType == payload.ActionTypeTaken && action.StepID == payload.StepID {
				actionCount++
			}
		}

		if actionCount >= payload.MinimumCount {
			err = TakeAction(task.SiteURL, recordID, task.StepID, payload.ActionType, payload.Comment)
			if err != nil {
				task.HandleError(recordID, "routeActionHistoryTally:", err)
			}
		}
	}
}
