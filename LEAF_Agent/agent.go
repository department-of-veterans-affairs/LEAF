package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"html"
	"log"
	"net/url"
	"strconv"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

type Task struct {
	TaskID          int           `json:"taskID"`
	SiteURL         string        `json:"siteURL"`
	StepID          string        `json:"stepID"`
	LastRun         time.Time     `json:"lastRun"`
	Instructions    []Instruction `json:"instructions"`
	Log             []TaskLog     `json:"log"`
	AverageDuration int           `json:"averageDuration"`
}

type Instruction struct {
	Type    string `json:"type"`
	Payload any    `json:"payload"`
}

type TaskLog struct {
	Timestamp int64  `json:"timestamp"`
	Duration  int    `json:"duration"`
	Error     string `json:"error"`
}

func ParsePayload[T any](payload any) T {
	b, _ := json.Marshal(payload)

	var result T
	json.Unmarshal(b, &result)
	return result
}

func ExecuteTask(task Task) {
	defer wg.Done()

	startTime := time.Now()
	log.Println("Executing Task ID#", task.TaskID)
	var err error
loop:
	for _, ins := range task.Instructions {
		switch ins.Type {
		case "route":
			if err = route(task, ParsePayload[RoutePayload](ins.Payload)); err != nil {
				log.Println("Error executing", ins.Type, ": ", err)
				break loop
			}
		case "routeConditionalData":
			if err = routeConditionalData(task, ParsePayload[RouteConditionalDataPayload](ins.Payload)); err != nil {
				log.Println("Error executing", ins.Type, ": ", err)
				break loop
			}
		case "routeActionHistoryTally":
			if err = routeActionHistoryTally(task, ParsePayload[RouteActionHistoryTallyPayload](ins.Payload)); err != nil {
				log.Println("Error executing", ins.Type, ": ", err)
				break loop
			}
		case "routeAfterHolding":
			if err = routeAfterHolding(task, ParsePayload[RouteAfterHoldingPayload](ins.Payload)); err != nil {
				log.Println("Error executing", ins.Type, ": ", err)
				break loop
			}
		case "routeLLM":
			if err = routeLLM(task, ParsePayload[RouteLLMPayload](ins.Payload)); err != nil {
				log.Println("Error executing", ins.Type, ": ", err)
				break loop
			}
		case "updateDataLLMCategorization":
			if err = updateDataLLMCategorization(task, ParsePayload[UpdateDataLLMCategorizationPayload](ins.Payload)); err != nil {
				log.Println("Error executing", ins.Type, ": ", err)
				break loop
			}
		default:
			err = errors.New("Unsupported instruction type: " + ins.Type + "Task ID# " + strconv.Itoa(task.TaskID))
			log.Println("Unsupported instruction type: ", ins.Type, "Task ID#", task.TaskID)
			break loop
		}
	}

	taskDuration := time.Now().Sub(startTime)
	LogTask(task, taskDuration, err)
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

	res, err := FormQuery(`https://`+HTTP_HOST+`/platform/agent/`, q, "&x-filterData=recordID,stepID,submitted")
	if err != nil {
		return fmt.Errorf("Error querying active tasks: %w", err)
	}

	// Get all active tasks
	activeTasks := make(map[string]query.Record)
	for _, v := range res {
		// key: siteURL + stepID
		if v.StepID == 2 {
			// Remove if duplicate
			key := v.S1["id2"] + v.S1["id3"]
			_, exists := activeTasks[key]
			if !exists {
				activeTasks[key] = v
			} else {
				err := TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, v.RecordID, "2", "Decommission", "")
				if err != nil {
					return fmt.Errorf("Error decommissioning duplicate task: %w", err)
				}
			}
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
					return fmt.Errorf("Error decommissioning older task: %w", err)
				}
			}

			err := TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, recordID, "1", "Activate", "")
			if err != nil {
				return fmt.Errorf("Error activating task: %w", err)
			}
		}
	}

	return nil
}

func FindTasks() ([]Task, error) {
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    "2",
			},
		},
		GetData: []int{2, 3, 4, 6, 8, 9},
	}

	records, err := FormQuery("https://"+HTTP_HOST+"/platform/agent/", query, "&x-filterData=")
	if err != nil {
		return nil, err
	}

	var tasks []Task

	for i, v := range records {
		var instructions []Instruction
		decodedInstruction := html.UnescapeString(v.S1["id4"])
		err := json.Unmarshal([]byte(decodedInstruction), &instructions)
		if err != nil {
			log.Println("Error unmarshalling instructions:", err, "Task ID#", i)
		}
		timeStamp, _ := strconv.ParseInt(v.S1["id6"], 10, 64)
		lastRun := time.Unix(timeStamp, 0)

		var taskLog []TaskLog
		decodedLog := html.UnescapeString(v.S1["id9"])
		if decodedLog != "" {
			err = json.Unmarshal([]byte(decodedLog), &taskLog)
			if err != nil {
				log.Println("Error unmarshalling log:", err, "Task ID#", i)
			}
		}

		task := Task{
			TaskID:       i,
			SiteURL:      v.S1["id2"],
			StepID:       v.S1["id3"],
			LastRun:      lastRun,
			Instructions: instructions,
			Log:          taskLog,
		}
		tasks = append(tasks, task)
	}

	return tasks, nil
}

func LogTask(task Task, taskDuration time.Duration, taskError error) {
	currentTime := strconv.FormatInt(time.Now().Unix(), 10)

	values := url.Values{}
	if taskError == nil {
		values.Add("6", currentTime) // timestamp for last successful run
	}

	// Prep task log, calculate average duration
	errMsg := ""
	if taskError != nil {
		errMsg = taskError.Error()
	}
	task.Log = append(task.Log, TaskLog{
		Timestamp: time.Now().Unix(),
		Duration:  int(taskDuration.Seconds()),
		Error:     errMsg,
	})
	if len(task.Log) > 30 {
		task.Log = task.Log[len(task.Log)-30:]
	}

	// Calculate average duration
	var totalDuration int
	for _, log := range task.Log {
		totalDuration += log.Duration
	}
	averageDuration := totalDuration / len(task.Log)
	values.Add("8", strconv.Itoa(averageDuration))

	taskLog, _ := json.Marshal(task.Log)
	values.Add("9", string(taskLog))

	HttpPost(`https://`+HTTP_HOST+`/platform/agent/api/form/`+strconv.Itoa(task.TaskID), values)
}
