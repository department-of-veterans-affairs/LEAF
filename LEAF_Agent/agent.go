package main

import (
	"log"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type Task struct {
	TaskID       int           `json:"taskID"`
	SiteURL      string        `json:"siteURL"`
	StepID       string        `json:"stepID"`
	LastRun      time.Time     `json:"lastRun"`
	Instructions []Instruction `json:"instructions"`
}

type Instruction struct {
	Type       string      `json:"type"`
	ActionType string      `json:"actionType,omitempty"`
	Query      query.Query `json:"query"`
}

func ExecuteTask(t Task) {
	log.Println("Executing Task ID# ", t.TaskID)

}
