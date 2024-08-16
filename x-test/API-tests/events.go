package main

type WorkflowEventsResponse []WorkflowEvent

type WorkflowEvent struct{
	EventID             string `json:"eventID"`
	EventDescription    string `json:"eventDescription"`
	EventType           string `json:"eventType"`
	EventData           string `json:"eventData"`
}

type EmailTemplatesRecord struct{
	DisplayName         string `displayName`
	FileName            string `fileName`
	EmailToFileName     string `emailTo`
	EmailCcFileName     string `emailCc`
	SubjectFileName     string `subject`
}

type EmailTemplatesResponse []EmailTemplatesRecord
