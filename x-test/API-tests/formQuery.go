package main

type FormQueryResponse map[int]FormQueryRecord

type FormQueryRecord struct {
	RecordID                int                      `json:"recordID"`
	ServiceID               int                      `json:"serviceID"`
	Date                    int                      `json:"date"`
	UserID                  string                   `json:"userID"`
	Title                   string                   `json:"title"`
	Priority                int                      `json:"priority"`
	LastStatus              string                   `json:"lastStatus"`
	Submitted               int                      `json:"submitted"`
	Deleted                 int                      `json:"deleted"`
	IsWritableUser          int                      `json:"isWritableUser"`
	IsWritableGroup         int                      `json:"isWritableGroup"`
	Service                 string                   `json:"service"`
	AbbreviatedService      string                   `json:"abbreviatedService"`
	GroupID                 int                      `json:"groupID"`
	StepID                  int                      `json:"stepID"`
	BlockingStepID          int                      `json:"blockingStepID"`
	LastNotified            string                   `json:"lastNotified"`
	InitialNotificationSent int                      `json:"initialNotificationSent"`
	StepTitle               string                   `json:"stepTitle"`
	CategoryNames           []string                 `json:"categoryNames"`
	CategoryIDs             []string                 `json:"categoryIDs"`
	DestructionAge          int                      `json:"destructionAge"`
	ActionHistory           []FormQueryActionHistory `json:"action_history"`
}

type FormQueryActionHistory struct {
	RecordID            int    `json:"recordID"`
	StepID              int    `json:"stepID"`
	UserID              string `json:"userID"`
	Time                int    `json:"time"`
	Description         string `json:"description"`
	ActionTextPasttense string `json:"actionTextPasttense"`
	ActionType          string `json:"actionType"`
	Comment             string `json:"comment"`
	ApproverName        string `json:"approverName"`
}
