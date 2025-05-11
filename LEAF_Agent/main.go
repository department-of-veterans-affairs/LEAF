package main

import (
	"crypto/tls"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"os"
	"strconv"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

var client *http.Client
var AGENT_TOKEN = os.Getenv("AGENT_TOKEN")
var HTTP_HOST = os.Getenv("APP_HTTP_HOST")

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	var tr = &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}

	var cookieJar, _ = cookiejar.New(nil)
	client = &http.Client{
		Transport: tr,
		Timeout:   time.Second * 5,
		Jar:       cookieJar,
	}

	log.Println("Starting LEAF Agent Coordinator...")

	for {
		err := UpdateTasks()
		if err != nil {
			log.Println("Error updating tasks:", err)
		}

		tasks, err := FindTasks()
		if err != nil {
			log.Println("Error finding tasks:", err)
		}

		for _, task := range tasks {
			ExecuteTask(task)
		}

		time.Sleep(10 * time.Second)
	}
}

func FindTasks() ([]Task, error) {
	res, err := HttpGet(`https://` + HTTP_HOST + `/platform/agent/api/form/query/?q={"terms":[{"id":"stepID","operator":"=","match":"2","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":[],"sort":{},"getData":["4","2","5","3","8"]}&x-filterData=`)
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
		json.Unmarshal([]byte(v.S1["id4"]), &instructions)
		timeStamp, _ := strconv.ParseInt(v.S1["id8"], 10, 64)
		log.Println(timeStamp)
		lastRun := time.Unix(timeStamp, 0)

		task := Task{
			TaskID:       i,
			SiteURL:      v.S1["id2"],
			StepID:       v.S1["id5"],
			LastRun:      lastRun,
			Instructions: instructions,
		}
		tasks = append(tasks, task)
	}

	return tasks, nil
}

func TakeAction(siteURL string, recID int, stpID int, actionType string, comment string) {
	recordID := strconv.Itoa(recID)
	stepID := strconv.Itoa(stpID)

	values := url.Values{}
	values.Add("dependencyID", "-4")
	values.Add("stepID", stepID)
	values.Add("actionType", actionType)
	values.Add("comment", comment)

	HttpPost(siteURL+"formWorkflow/"+recordID+"/apply'", values)
}

// UpdateRecord updates a record with the provided data.
// data is a map where the keys are field IDs (indicatorID) and the values are written into the record matching recID
func UpdateRecord(siteURL string, recID int, data map[int]string) {
	recordID := strconv.Itoa(recID)

	values := url.Values{}

	for k, v := range data {
		values.Add(strconv.Itoa(k), v)
	}

	HttpPost(siteURL+"form/"+recordID, values)
}
