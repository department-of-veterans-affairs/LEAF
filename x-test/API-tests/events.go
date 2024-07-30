package main

type WorkflowEventsResponse []WorkflowEvent

type WorkflowEvent struct{
	EventID             string `json:"eventID"`
	EventDescription    string `json:"eventDescription"`
	EventType           string `json:"eventType"`
	EventData           string `json:"eventData"`
}