package agent

import (
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type HoldForDurationPayload struct {
	SecondsToHold int64 `json:"secondsToHold"`
}

// holdForDuration holds records for SecondsToHold duration.
// Records that do not exceed the duration are removed from task.Records
func (a Agent) holdForDuration(task *Task, payload HoldForDurationPayload) {
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

	records, err := a.FormQuery(task.SiteURL, query, "&x-filterData=submitted,stepFulfillmentOnly")
	if err != nil {
		task.HandleError(0, "routeAfterHolding:", err)
	}

	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	now := time.Now()
	for recordID, record := range records {
		// Only process records within the current set
		if _, exists := task.Records[recordID]; !exists {
			continue
		}

		lastActionTimestamp := int64(record.Submitted)
		if len(record.StepFulfillmentOnly) > 0 {
			lastActionTimestamp = int64(record.StepFulfillmentOnly[0].Time)
		}

		// Remove records from the current set if they have not been held for the specified duration
		if now.Unix()-lastActionTimestamp < payload.SecondsToHold {
			delete(task.Records, recordID)
		}
	}
}
