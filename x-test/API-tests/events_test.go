package main

import (
	"testing"
	"github.com/google/go-cmp/cmp"
	"encoding/json"
	"io"
	"net/url"
)

func getEvent(url string) (WorkflowEventsResponse, error) {
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m WorkflowEventsResponse
	err := json.Unmarshal(b, &m)
	if err != nil {
		return nil, err
	}
	return m, err
}

func postEvent(postUrl string, event WorkflowEvent) (string, error) {
	postData := url.Values{}
	postData.Set("name", event.EventID)
	postData.Set("description", event.EventDescription)
	postData.Set("type", event.EventType)
	//postData.Set("data", event.EventData)
	postData.Set("CSRFToken", CsrfToken)

	res, err := client.PostForm(postUrl, postData)
	if err != nil {
		return "", err
	}

	bodyBytes, err := io.ReadAll(res.Body)
	if err != nil {
		return "", err
	}
	return string(bodyBytes), nil
}


func TestEvents_NewValidEmailEvent(t *testing.T) {
	ev_valid := WorkflowEvent{
		EventID: "CustomEvent_event_valid",
		EventDescription:  "test event description",
		EventType:  "Email",
		EventData: "",
	}

	res, err := postEvent(RootURL+`api/workflow/events`, ev_valid)
	if err != nil {
		t.Error(err)
	}

	got := res
	want := `"1"`
	if !cmp.Equal(got, want) {
		t.Errorf("event should have saved because name and descr are valid. got = %v, want = %v", got, want)
	}
}

func TestEvents_DuplicateDescriptionEmailEvent(t *testing.T) {
	ev_desc_dup := WorkflowEvent{
		EventID: "CustomEvent_event_desc_dup",
		EventDescription:  "test event description",
		EventType:  "Email",
		EventData: "",
	}

	res, err := postEvent(RootURL+`api/workflow/events`, ev_desc_dup)
	if err != nil {
		t.Error(err)
	}
	got := res
	want := `"This description has already been used, please use another one."`
	if !cmp.Equal(got, want) {
		t.Errorf("string for alert should be returned because description is not unique.  got = %v, want = %v", got, want)
	}
}