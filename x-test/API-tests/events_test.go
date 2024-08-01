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

	var ev WorkflowEventsResponse
	err := json.Unmarshal(b, &ev)
	if err != nil {
		return nil, err
	}
	return ev, err
}

func postEvent(postUrl string, event WorkflowEvent, addOptions bool) (string, error) {
	postData := url.Values{}
	postData.Set("name", event.EventID)
	postData.Set("description", event.EventDescription)
	postData.Set("type", event.EventType)
	if(addOptions == true) {
		//revisit: more ideal as a struct, but there are key and type differences that complicate this
		postData.Set("data[Notify Requestor]", "true")
		postData.Set("data[Notify Next]", "true")
		postData.Set("data[Notify Group]", "203")
	}
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
	eventName := "CustomEvent_event_valid"
	ev_valid := WorkflowEvent{
		EventID: eventName,
		EventDescription:  "test event description",
		EventType:  "Email",
	}
	res, err := postEvent(RootURL+`api/workflow/events`, ev_valid, true)
	if err != nil {
		t.Error(err)
	}

	got := res
	want := `"1"`
	if !cmp.Equal(got, want) {
		t.Errorf("event should have saved because name and descr are valid. got = %v, want = %v", got, want)
	}
	event, err := getEvent(RootURL + `api/workflow/event/_` + eventName)
	if err != nil {
		t.Error(err)
	}
	got = event[0].EventID
	want = ev_valid.EventID
	if !cmp.Equal(got, want) {
		t.Errorf("EventID not as expected.  got = %v, want = %v", got, want)
	}
	got = event[0].EventDescription
	want = ev_valid.EventDescription
	if !cmp.Equal(got, want) {
		t.Errorf("EventDescription not as expected.  got = %v, want = %v", got, want)
	}
	got = event[0].EventType
	want = ev_valid.EventType
	if !cmp.Equal(got, want) {
		t.Errorf("EventType not as expected.  got = %v, want = %v", got, want)
	}
	got = event[0].EventData
	want = `{"NotifyRequestor":"true","NotifyNext":"true","NotifyGroup":"203"}`
	if !cmp.Equal(got, want) {
		t.Errorf("EventData not as expected.  got = %v, want = %v", got, want)
	}
}


func TestEvents_ReservedPrefixes(t *testing.T) {
	ev_leafsecure := WorkflowEvent{
		EventID: "LeafSecure_prefix",
		EventDescription:  "prefix is reserved 1",
		EventType:  "Email",
	}
	ev_std_email := WorkflowEvent{
		EventID: "std_email_prefix",
		EventDescription:  "prefix is reserved 2",
		EventType:  "Email",
	}

	res, err := postEvent(RootURL+`api/workflow/events`, ev_leafsecure, false)
	if err != nil {
		t.Error(err)
	}
	got := res
	want := `"Event Already Exists."`
	if !cmp.Equal(got, want) {
		t.Errorf("event should not post because leafsecure prefix is reserved. got = %v, want = %v", got, want)
	}

	res, err = postEvent(RootURL+`api/workflow/events`, ev_std_email, false)
	if err != nil {
		t.Error(err)
	}
	got = res
	want = `"Event Already Exists."`
	if !cmp.Equal(got, want) {
		t.Errorf("event should not post because std_email prefix is reserved. got = %v, want = %v", got, want)
	}
}

func TestEvents_DuplicateDescriptionEmailEvent(t *testing.T) {
	ev_desc_dup := WorkflowEvent{
		EventID: "CustomEvent_event_desc_dup",
		EventDescription:  "test event description",
		EventType:  "Email",
	}

	res, err := postEvent(RootURL+`api/workflow/events`, ev_desc_dup, false)
	if err != nil {
		t.Error(err)
	}
	got := res
	want := `"This description has already been used, please use another one."`
	if !cmp.Equal(got, want) {
		t.Errorf("alert text should be returned because description is not unique.  got = %v, want = %v", got, want)
	}
}