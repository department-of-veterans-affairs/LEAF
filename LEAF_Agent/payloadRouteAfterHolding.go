package main

import (
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RouteAfterHoldingPayload struct {
	ActionType    string `json:"actionType"`
	Comment       string `json:"comment,omitempty"`
	SecondsToHold int64  `json:"secondsToHold"`
}

// route executes an action, payload.ActionType, for all records matching the task
func routeAfterHolding(task Task, payload RouteAfterHoldingPayload) error {
	// Initialize query. At minimum it should only return records that match the stepID
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    task.StepID,
			},
		},
		Joins: []string{"stepFulfillmentOnly"},
	}

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=submitted,stepFulfillmentOnly")
	if err != nil {
		return err
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return nil
	}

	now := time.Now()
	for recordID, record := range records {
		// Only process records within the current set
		if _, ok := task.CurrentRecords[recordID]; !ok {
			continue
		}

		lastActionTimestamp := int64(record.Submitted)
		if len(record.StepFulfillmentOnly) > 0 {
			lastActionTimestamp = int64(record.StepFulfillmentOnly[0].Time)
		}

		if now.Unix()-lastActionTimestamp > payload.SecondsToHold {
			err = TakeAction(task.SiteURL, recordID, task.StepID, payload.ActionType, payload.Comment)
			if err != nil {
				return err
			}
		}
	}

	return nil
}
