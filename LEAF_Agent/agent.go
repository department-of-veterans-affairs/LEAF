package main

import (
	"encoding/json"
	"fmt"
	"html"
	"log"
	"net/url"
	"strconv"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

func ParsePayload[T any](payload any) T {
	b, _ := json.Marshal(payload)

	var result T
	json.Unmarshal(b, &result)
	return result
}

func ExecuteTask(task Task) {
	var records query.Response
	var err error

	startTime := time.Now()

	defer func() {
		// only log if there were records to process
		if len(records) > 0 {
			LogTask(task, time.Since(startTime))
		}
	}()

	log.Println("Executing Task ID#", task.TaskID)

	// Get list of records to process
	task.Records = make(map[int]struct{})
	query := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "=",
				Match:    task.StepID,
			},
		},
	}
	records, err = FormQuery(task.SiteURL, query, "&x-filterData=")
	if err != nil {
		return
	}
	// Exit early if no records match the query
	if len(records) == 0 {
		return
	}

	for recordID := range records {
		task.Records[recordID] = struct{}{}
	}

	// Process task's instructions
loop:
	for _, ins := range task.Instructions {
		if len(task.Records) == 0 {
			break
		}

		switch ins.Type {
		case "annotation":
			// no-op. for documentation purposes only
		case "route":
			route(&task, ParsePayload[RoutePayload](ins.Payload))

		case "routeConditionalData":
			routeConditionalData(&task, ParsePayload[RouteConditionalDataPayload](ins.Payload))

		case "routeActionHistoryTally":
			routeActionHistoryTally(&task, ParsePayload[RouteActionHistoryTallyPayload](ins.Payload))

		case "holdForDuration":
			holdForDuration(&task, ParsePayload[HoldForDurationPayload](ins.Payload))

		case "updateDataConditional":
			updateDataConditional(&task, ParsePayload[UpdateDataConditionalPayload](ins.Payload))

		case "validateInitiatorIsLocalAdmin":
			validateInitiatorIsLocalAdmin(&task, ParsePayload[ValidateInitiatorIsLocalAdmin](ins.Payload))

		// Instructions utilizing a LLM
		case "routeLLM":
			routeLLM(&task, ParsePayload[RouteLLMPayload](ins.Payload))

		case "updateDataLLMCategorization":
			updateDataLLMCategorization(&task, ParsePayload[UpdateDataLLMCategorizationPayload](ins.Payload))

		case "updateDataLLMLabel":
			updateDataLLMLabel(&task, ParsePayload[UpdateDataLLMLabelPayload](ins.Payload))

		case "updateTitleLLMLabel":
			updateTitleLLMLabel(&task, ParsePayload[UpdateTitleLLMLabelPayload](ins.Payload))

		case "updateData4BLLM":
			updateData4BLLM(&task, ParsePayload[UpdateData4BLLMPayload](ins.Payload))

		default:
			log.Println("Unsupported instruction type: ", ins.Type, "Task ID#", task.TaskID)
			break loop
		}
	}
}

// ReviewTasks ensures active tasks do not contain duplicates, and promotes pending tasks to an active status
// This function is not thread safe and must be run sequentially
func ReviewTasks() error {
	q := query.Query{
		Terms: []query.Term{
			{
				ID:       "stepID",
				Operator: "!=",
				Match:    "resolved",
			},
		},
		Joins:   []string{"status", "initiator"},
		GetData: []int{2, 3}, // id2 = siteURL, id3 = stepID
	}

	res, err := FormQuery(`https://`+HTTP_HOST+`/platform/agent/`, q, "&x-filterData=recordID,stepID,submitted,userName")
	if err != nil {
		return fmt.Errorf("error querying active tasks: %w", err)
	}

	// Check active tasks for duplicates
	activeTasks := make(map[string]query.Record)
	for _, v := range res {
		// key: siteURL + stepID
		if v.StepID == 2 { // StepID 2 = Active Tasks
			// Remove if duplicate
			key := v.S1["id2"] + v.S1["id3"]
			_, exists := activeTasks[key]
			if !exists {
				activeTasks[key] = v
			} else {
				err := TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, v.RecordID, "2", "Decommission", "")
				if err != nil {
					return fmt.Errorf("error decommissioning duplicate task: %w", err)
				}
			}
		}
	}

	// Check tasks in staging area
	for recordID, v := range res {
		if v.StepID == 1 { // StepID 1 = Tasks in staging area

			// Check if the task's initiator is a local admin of the site associated with the task
			isAdmin, err := IsSiteAdmin(v.S1["id2"], v.UserName)
			if err != nil {
				return fmt.Errorf("error checking site admin: %w", err)
			}

			if !isAdmin {
				err := TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, recordID, "1", "Decommission", "Initiator must be an admin of the site associated with the task")
				if err != nil {
					return fmt.Errorf("error removing unauthorized task: %w", err)
				}
				continue
			}

			// Replace tasks with newer ones, if present
			key := v.S1["id2"] + v.S1["id3"]
			_, hasNewer := activeTasks[key]
			if hasNewer {
				err := TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, activeTasks[key].RecordID, "2", "Decommission", "")
				if err != nil {
					return fmt.Errorf("error decommissioning older task: %w", err)
				}
			}

			err = TakeAction(`https://`+HTTP_HOST+`/platform/agent/`, recordID, "1", "Activate", "")
			if err != nil {
				return fmt.Errorf("error activating task: %w", err)
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

func LogTask(task Task, taskDuration time.Duration) {
	currentTime := strconv.FormatInt(time.Now().Unix(), 10)

	values := url.Values{}
	if len(task.Errors) == 0 {
		values.Add("6", currentTime) // timestamp for last successful run
	}

	// Prep task log, calculate average duration
	task.Log = append(task.Log, TaskLog{
		Timestamp: time.Now().Unix(),
		Duration:  int(taskDuration.Milliseconds()),
		Errors:    task.Errors,
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

	_, err := HttpPost(`https://`+HTTP_HOST+`/platform/agent/api/form/`+strconv.Itoa(task.TaskID), values)
	if err != nil {
		log.Println("LogTask: Error logging task: ", err)
	}
}
