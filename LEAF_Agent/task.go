package main

import (
	"log"
	"time"
)

type Task struct {
	TaskID       int           `json:"taskID"`
	SiteURL      string        `json:"siteURL"`
	StepID       string        `json:"stepID"`
	Instructions []Instruction `json:"instructions"`

	// Map of records in the current working set. Indexed by recordID (int)
	// The record is in the set if it exists in the map
	// Values aren't needed, so a zero-sized struct{} is used as its "value"
	Records map[int]struct{}

	Errors []TaskError

	Log             []TaskLog `json:"log"`
	LastRun         time.Time `json:"lastRun"`
	AverageDuration int       `json:"averageDuration"`
}

/*
HandleError logs the error for the given recordID and removes the record from the current working record set in t.Records.
For non-recoverable errors, recordID should be set to 0 to empty the current working set.
*/
func (t *Task) HandleError(recordID int, functionName string, err error) {
	t.Errors = append(t.Errors, TaskError{RecordID: recordID, Error: err.Error()})
	log.Println(functionName, err)

	if recordID != 0 {
		delete(t.Records, recordID)
	} else {
		clear(t.Records)
	}
}

type Instruction struct {
	Type    string `json:"type"`
	Payload any    `json:"payload"`
}

type TaskLog struct {
	Timestamp int64       `json:"timestamp"`
	Duration  int         `json:"duration"`
	Errors    []TaskError `json:"errors,omitempty"`
}

type TaskError struct {
	RecordID int    `json:"recordID"`
	Error    string `json:"error"`
}
