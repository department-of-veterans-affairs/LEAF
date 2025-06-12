package query

import (
	"encoding/json"
)

// Response represents the response structure for the "form/query" API endpoint
// The map's key is the record ID
type Response map[int]Record

// ResponseCompat provides compatibility with the current response format
//
// TODO: if x-filterData= is empty, api/form/query responses should contain empty objects instead of arrays
type ResponseCompat map[int][]string

// UnmarshallJSON provides compatibility, see ResponseCompat
func (r *Response) UnmarshalJSON(b []byte) error {
	var temp map[int]Record
	err := json.Unmarshal(b, &temp)
	if err != nil {
		var rc ResponseCompat
		err = json.Unmarshal(b, &rc)
		if err == nil {
			res := make(Response)
			for k := range rc {
				res[k] = Record{}
			}
			*r = res
		} else if string(b) == "[]" {
			return nil
		} else {
			return err
		}
	} else {
		*r = Response(temp)
	}

	return nil
}

// Record represents the structure of a single record in the response
type Record struct {
	RecordID                int                    `json:"recordID"`
	ServiceID               int                    `json:"serviceID"`
	Date                    int                    `json:"date"`
	UserID                  string                 `json:"userID"`
	Title                   string                 `json:"title"`
	Priority                int                    `json:"priority"`
	LastStatus              string                 `json:"lastStatus"`
	Submitted               int                    `json:"submitted"`
	Deleted                 int                    `json:"deleted"`
	IsWritableUser          int                    `json:"isWritableUser"`
	IsWritableGroup         int                    `json:"isWritableGroup"`
	Service                 string                 `json:"service"`
	AbbreviatedService      string                 `json:"abbreviatedService"`
	GroupID                 int                    `json:"groupID"`
	StepID                  int                    `json:"stepID"`
	BlockingStepID          int                    `json:"blockingStepID"`
	LastNotified            string                 `json:"lastNotified"`
	InitialNotificationSent int                    `json:"initialNotificationSent"`
	StepTitle               string                 `json:"stepTitle"`
	CategoryNames           []string               `json:"categoryNames"`
	CategoryIDs             []string               `json:"categoryIDs"`
	DestructionAge          int                    `json:"destructionAge"`
	ActionHistory           []ActionHistory        `json:"action_history"`
	S1                      Data                   `json:"s1"`
	UnfilledDependencyData  UnfilledDependencyData `json:"unfilledDependencyData"`
	UserMetadata            OrgchartEmployee       `json:"userMetadata"`
	FirstName               string                 `json:"firstName"`
	LastName                string                 `json:"lastName"`
	UserName                string                 `json:"userName"`
	StepFulfillmentOnly     []StepFulfillment      `json:"stepFulfillmentOnly"`
}

// ActionHistory represents an action history event for a record
type ActionHistory struct {
	RecordID            int              `json:"recordID"`
	StepID              int              `json:"stepID"`
	UserID              string           `json:"userID"`
	Time                int              `json:"time"`
	Description         string           `json:"description"`
	ActionTextPasttense string           `json:"actionTextPasttense"`
	ActionType          string           `json:"actionType"`
	Comment             string           `json:"comment"`
	ApproverName        string           `json:"approverName"`
	UserMetadata        OrgchartEmployee `json:"userMetadata"`
}

// Data represents the dynamic data fields in the record
// The map's key is "id" + the indicatorID of the field
// TODO: Migrate the key format from "id###"" to "###"
type Data map[string]string

type OrgchartEmployee struct {
	FirstName  string `json:"firstName"`
	LastName   string `json:"lastName"`
	MiddleName string `json:"middleName"`
	Email      string `json:"email"`
	UserName   string `json:"userName"`
	EmpUID     int    `json:"empUID"`
}

type UnfilledDependencyData map[string]UnfilledDependency

type UnfilledDependency struct {
	Description  string `json:"description"`
	ApproverName string `json:"approverName"`
	ApproverUID  string `json:"approverUID"`
}

type StepFulfillment struct {
	StepID int `json:"stepID"`
	Time   int `json:"time"`
}
