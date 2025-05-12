package main

import (
	"encoding/json"
	"errors"
	"html"
	"io"
	"log"
	"net/url"
	"strconv"
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
	Type    string `json:"type"`
	Payload any    `json:"payload"`
}

type RouteConditionalDataPayload struct {
	ActionType string      `json:"actionType"`
	Query      query.Query `json:"query"`
}

func ParsePayload[T any](payload any) T {
	b, _ := json.Marshal(payload)

	var result T
	json.Unmarshal(b, &result)
	return result
}

func ExecuteTask(task Task) {
	log.Println("Executing Task ID#", task.TaskID)
	var err error
loop:
	for _, ins := range task.Instructions {
		switch ins.Type {
		case "route-conditional-data":
			if err = routeConditionalData(task, ParsePayload[RouteConditionalDataPayload](ins.Payload)); err != nil {
				log.Println("Error executing route-conditional-data: ", err)
				break loop
			}
		default:
			err = errors.New("Unsupported instruction type: " + ins.Type + "Task ID# " + strconv.Itoa(task.TaskID))
			log.Println("Unsupported instruction type: ", ins.Type, "Task ID#", task.TaskID)
			break loop
		}
	}

	if err == nil {
		LogSucessfulTask(task.TaskID)
	}
}

func routeConditionalData(task Task, payload RouteConditionalDataPayload) error {
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

	records, err := FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		return err
	}

	for recordID := range records {
		TakeAction(task.SiteURL, recordID, task.StepID, payload.ActionType, "")
	}

	return nil
}

func UpdateTasks() error {
	q := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "!=",
				Match:    "resolved",
			},
		},
		Joins:   []string{"status"},
		GetData: []int{2, 3}, // id2 = siteURL, id3 = stepID
	}

	res, _ := FormQuery(`https://`+HTTP_HOST+`/platform/agent/`, q, "&x-filterData=recordID,stepID,submitted")

	// TODO: Prevent duplicates

	// Get all active tasks
	activeTasks := make(map[string]query.Record)
	for _, v := range res {
		// key: siteURL + stepID
		if v.StepID == 2 {
			activeTasks[v.S1["id2"]+v.S1["id3"]] = v
		}
	}

	// Replace tasks with newer ones, if present
	for recordID, v := range res {
		if v.StepID == 1 {
			key := v.S1["id2"] + v.S1["id3"]
			_, hasNewer := activeTasks[key]
			if hasNewer {
				err := TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, activeTasks[key].RecordID, "2", "Decommission", "")
				if err != nil {
					return err
				}
			}

			err := TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, recordID, "1", "Activate", "")
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func FindTasks() ([]Task, error) {
	res, err := HttpGet(`https://` + HTTP_HOST + `/platform/agent/api/form/query/?q={"terms":[{"id":"stepID","operator":"=","match":"2","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":[],"sort":{},"getData":["2","3","4","6"]}&x-filterData=`)
	if err != nil {
		return nil, err
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	var r query.Response
	json.Unmarshal(b, &r)

	var tasks []Task

	for i, v := range r {
		var instructions []Instruction
		decodedInstruction := html.UnescapeString(v.S1["id4"])
		err := json.Unmarshal([]byte(decodedInstruction), &instructions)
		if err != nil {
			log.Println("Error unmarshalling instructions:", err, "Task ID#", i)
		}
		timeStamp, _ := strconv.ParseInt(v.S1["id6"], 10, 64)
		lastRun := time.Unix(timeStamp, 0)

		task := Task{
			TaskID:       i,
			SiteURL:      v.S1["id2"],
			StepID:       v.S1["id3"],
			LastRun:      lastRun,
			Instructions: instructions,
		}
		tasks = append(tasks, task)
	}

	return tasks, nil
}

func LogSucessfulTask(taskID int) {
	currentTime := strconv.FormatInt(time.Now().Unix(), 10)

	values := url.Values{}
	values.Add("6", currentTime)
	HttpPost(`https://`+HTTP_HOST+`/platform/agent/api/form/`+strconv.Itoa(taskID), values)
}
