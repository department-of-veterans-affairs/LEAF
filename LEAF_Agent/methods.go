package main

import (
	"errors"
	"io"
	"log"
	"net/url"
	"strconv"
)

func TakeAction(siteURL string, recID int, stepID string, actionType string, comment string) error {
	recordID := strconv.Itoa(recID)

	values := url.Values{}
	values.Add("dependencyID", "-4")
	values.Add("stepID", stepID)
	values.Add("actionType", actionType)
	values.Add("comment", comment)

	endpoint := siteURL + "api/formWorkflow/" + recordID + "/apply"

	res, err := HttpPost(endpoint, values)
	if err != nil {
		log.Println("Error taking action:", endpoint, err)
		return err
	}

	if res.StatusCode == 200 {
		log.Println("Action taken successfully:", siteURL, recordID)
		return nil
	} else {
		errMsg, _ := io.ReadAll(res.Body)
		log.Println("Failed to take action:", endpoint, res.StatusCode, string(errMsg))
		return errors.New("Failed to take action: " + string(errMsg))
	}
}

// UpdateRecord updates a record with the provided data.
// data is a map where the keys are field IDs (indicatorID) and the values are written into the record matching recID
func UpdateRecord(siteURL string, recID int, data map[int]string) {
	recordID := strconv.Itoa(recID)

	values := url.Values{}

	for k, v := range data {
		values.Add(strconv.Itoa(k), v)
	}

	HttpPost(siteURL+"api/form/"+recordID, values)
}
