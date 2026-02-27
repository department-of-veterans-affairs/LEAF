package agent

import (
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type RouteConditionalDataPayload struct {
	ActionType string      `json:"actionType"`
	Query      query.Query `json:"query"`
	Comment    string      `json:"comment,omitempty"`
}

// routeConditionalData executes an action, payload.ActionType, for all records that match payload.Query AND the task's stepID.
func (a Agent) routeConditionalData(task *Task, payload RouteConditionalDataPayload) {
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

	records, err := a.FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		task.HandleError(0, "routeConditionalData:", err)
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

		err = a.TakeAction(task.SiteURL, recordID, task.StepID, payload.ActionType, payload.Comment)
		if err != nil {
			task.HandleError(recordID, "routeConditionalData:", err)
		}
	}
}
