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

	if res.StatusCode == 200 || res.StatusCode == 202 {
		log.Println("Action taken successfully: " + siteURL + "?a=printview&recordID=" + recordID)
		return nil
	} else {
		errMsg, _ := io.ReadAll(res.Body)
		log.Println("Failed to take action:", endpoint, res.StatusCode, string(errMsg))
		return errors.New("Failed to take action: " + string(errMsg))
	}
}

// UpdateRecord updates a record with the provided data.
// data is a map where the keys are field IDs (indicatorID) and the values are written into the record matching recID
func UpdateRecord(siteURL string, recID int, data map[int]string) error {
	recordID := strconv.Itoa(recID)

	values := url.Values{}

	for k, v := range data {
		values.Add(strconv.Itoa(k), v)
	}

	res, err := HttpPost(siteURL+"api/form/"+recordID, values)
	if err != nil {
		log.Println("Error updating record:", siteURL, recID)
		return err
	}

	if res.StatusCode == 200 {
		log.Println("Record updated:", siteURL+"?a=printview&recordID="+recordID)
		return nil
	} else {
		errMsg, _ := io.ReadAll(res.Body)
		log.Println("Failed to update record:", siteURL, recordID, res.StatusCode, string(errMsg))
		return errors.New("Failed to update record: " + string(errMsg))
	}
}

// UpdateTitle updates a record title
func UpdateTitle(siteURL string, recID int, title string) error {
	recordID := strconv.Itoa(recID)

	values := url.Values{}
	values.Add("title", title)

	res, err := HttpPost(siteURL+"api/form/"+recordID+"/title", values)
	if err != nil {
		log.Println("Error updating record title:", siteURL, recID)
		return err
	}

	if res.StatusCode == 200 {
		log.Println("Record title updated:", siteURL+"?a=printview&recordID="+recordID)
		return nil
	} else {
		errMsg, _ := io.ReadAll(res.Body)
		log.Println("Failed to update record title:", siteURL, recordID, res.StatusCode, string(errMsg))
		return errors.New("Failed to update record title: " + string(errMsg))
	}
}
