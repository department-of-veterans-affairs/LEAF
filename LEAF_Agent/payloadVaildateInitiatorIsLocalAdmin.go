package main

import (
	"fmt"
	"strconv"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type ValidateInitiatorIsLocalAdmin struct {
	ReadIndicatorID int    `json:"readIndicatorID"`
	Comment         string `json:"comment,omitempty"`
}

// validateInitiatorIsLocalAdmin checks if the record's initiator is a local admin for a given SiteURL
// provided by ReadIndicatorID
func validateInitiatorIsLocalAdmin(task *Task, payload ValidateInitiatorIsLocalAdmin) {
	// Initialize query. At minimum it should only return records that match the stepID
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    task.StepID,
			},
		},
		Joins:   []string{"initiator"},
		GetData: []int{payload.ReadIndicatorID},
	}

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=userName")
	if err != nil {
		task.HandleError(0, "validateInitiatorIsLocalAdmin:", err)
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

		// Get the list of admins for the provided SiteURL
		iID := strconv.Itoa(payload.ReadIndicatorID)
		admins, err := GetAdmins(record.S1["id"+iID])
		if err != nil {
			task.HandleError(recordID, "validateInitiatorIsLocalAdmin:", err)
			continue
		}

		for _, admin := range admins {
			if admin.Username != records[recordID].UserName {
				task.HandleError(recordID, "validateInitiatorIsLocalAdmin:", fmt.Errorf("initiator is not a local site admin"))
			}
		}
	}
}
