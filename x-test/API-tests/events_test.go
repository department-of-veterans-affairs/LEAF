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

func postEvent(postUrl string, event WorkflowEvent, options map[string]string) (string, error) {
	postData := url.Values{}
	postData.Set("name", event.EventID)
	postData.Set("description", event.EventDescription)
	postData.Set("type", event.EventType)
	for k, v := range options {
		postData.Set(k, v)
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

func getEmailTemplatesResponse(url string) (EmailTemplatesResponse, error) {
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var emailTemplatesResponse EmailTemplatesResponse
	err := json.Unmarshal(b, &emailTemplatesResponse)
	if err != nil {
		return nil, err
	}
	return emailTemplatesResponse, err
}

/* get a WorkflowEvent from a given eventID and confirm expected property values */
func confirmEventsRecordValues(t *testing.T, expectedEvent WorkflowEvent, expected_JSON_options string) {
	event, err := getEvent(RootURL + `api/workflow/event/_` + expectedEvent.EventID)
	if err != nil {
		t.Error(err)
	}
	got := event[0].EventID
	want := expectedEvent.EventID
	if !cmp.Equal(got, want) {
		t.Errorf("EventID not as expected.  got = %v, want = %v", got, want)
	}
	got = event[0].EventDescription
	want = expectedEvent.EventDescription
	if !cmp.Equal(got, want) {
		t.Errorf("EventDescription not as expected.  got = %v, want = %v", got, want)
	}
	got = event[0].EventType
	want = expectedEvent.EventType
	if !cmp.Equal(got, want) {
		t.Errorf("EventType not as expected.  got = %v, want = %v", got, want)
	}
	got = event[0].EventData
	want = expected_JSON_options
	if !cmp.Equal(got, want) {
		t.Errorf("EventData not as expected.  got = %v, want = %v", got, want)
	}
}

/*
* Get emailTemplates records and search by eventDescription / email_templates label.
* Confirm that a record is found and has the expected property values based on the eventID.
*/
func confirmEmailTemplatesRecordValues(t *testing.T, eventID string, eventDescription string) {
	emailTemplatesResponse, err := getEmailTemplatesResponse(RootURL + `api/emailTemplates`)
	if err != nil {
		t.Error(err)
	}
	var newEmailTemplatesRecord EmailTemplatesRecord
	for i := 0; i < len(emailTemplatesResponse); i++ {
		emailTempRec := emailTemplatesResponse[i];
		if(emailTempRec.DisplayName == eventDescription) {
			newEmailTemplatesRecord = emailTempRec
		}
	}
	if (newEmailTemplatesRecord.FileName == "") {
		t.Errorf("Did not find expected email templates record")
	} else {
		got := newEmailTemplatesRecord.FileName
		want := eventID + "_body.tpl"
		if !cmp.Equal(got, want) {
			t.Errorf("Did not find expected body file name.  got = %v, want = %v", got, want)
		}
		got = newEmailTemplatesRecord.EmailToFileName
		want = eventID + "_emailTo.tpl"
		if !cmp.Equal(got, want) {
			t.Errorf("Did not find expected emailTo file name.  got = %v, want = %v", got, want)
		}
		got = newEmailTemplatesRecord.EmailCcFileName
		want = eventID + "_emailCc.tpl"
		if !cmp.Equal(got, want) {
			t.Errorf("Did not find expected emailCc file name.  got = %v, want = %v", got, want)
		}
		got = newEmailTemplatesRecord.SubjectFileName
		want = eventID + "_subject.tpl"
		if !cmp.Equal(got, want) {
			t.Errorf("Did not find expected subject file name.  got = %v, want = %v", got, want)
		}
	}
}

/*
* Event posts successfully and associated events and email_templates table records have expected values
*/
func TestEvents_NewValidCustomEmailEvent(t *testing.T) {
	eventName := "CustomEvent_event_valid"
	optionsIn := map[string]string {
		"data[Notify Requestor]": "true",
		"data[Notify Next]": "true",
		"data[Notify Group]": "203",
	}
	expectedJSON := `{"NotifyRequestor":"true","NotifyNext":"true","NotifyGroup":"203"}`
	ev_valid := WorkflowEvent{
		EventID: eventName,
		EventDescription:  "test event description",
		EventType:  "Email",
	}
	res, err := postEvent(RootURL+`api/workflow/events`, ev_valid, optionsIn)
	if err != nil {
		t.Error(err)
	}

	got := res
	want := `"1"`
	if !cmp.Equal(got, want) {
		t.Errorf("event should have saved because name and descr are valid. got = %v, want = %v", got, want)
	}
	confirmEventsRecordValues(t, ev_valid, expectedJSON)

	confirmEmailTemplatesRecordValues(t, ev_valid.EventID, ev_valid.EventDescription)
}

func TestEvents_ReservedPrefixes_NotAllowed(t *testing.T) {
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

	res, err := postEvent(RootURL+`api/workflow/events`, ev_leafsecure, map[string]string{})
	if err != nil {
		t.Error(err)
	}
	got := res
	want := `"Event Already Exists."`
	if !cmp.Equal(got, want) {
		t.Errorf("event should not post because leafsecure prefix is reserved. got = %v, want = %v", got, want)
	}

	res, err = postEvent(RootURL+`api/workflow/events`, ev_std_email, map[string]string{})
	if err != nil {
		t.Error(err)
	}
	got = res
	want = `"Event Already Exists."`
	if !cmp.Equal(got, want) {
		t.Errorf("event should not post because std_email prefix is reserved. got = %v, want = %v", got, want)
	}
}

func TestEvents_DuplicateDescription_NotAllowed(t *testing.T) {
	ev_desc_dup := WorkflowEvent{
		EventID: "CustomEvent_event_desc_dup",
		EventDescription:  "test event description",
		EventType:  "Email",
	}

	res, err := postEvent(RootURL+`api/workflow/events`, ev_desc_dup, map[string]string{})
	if err != nil {
		t.Error(err)
	}
	got := res
	want := `"This description has already been used, please use another one."`
	if !cmp.Equal(got, want) {
		t.Errorf("alert text should be returned because description is not unique.  got = %v, want = %v", got, want)
	}
}

func TestEvents_EditValidCustomEmailEvent(t *testing.T) {
	oldEventName := "CustomEvent_event_valid"
	newEventName := "CustomEvent_event_valid_edited"
	newOptionsIn := map[string]string {
		"data[Notify Requestor]": "false",
		"data[Notify Next]": "false",
		"data[Notify Group]": "101",
		"newName": newEventName,
	}
	newExpectedJSON := `{"NotifyRequestor":"false","NotifyNext":"false","NotifyGroup":"101"}`
	new_ev_valid := WorkflowEvent{
		EventID: newEventName,
		EventDescription:  "test edited event description",
		EventType:  "Email",
	}
	res, err := postEvent(RootURL+`api/workflow/editEvent/_` + oldEventName, new_ev_valid, newOptionsIn)
	if err != nil {
		t.Error(err)
	}

	got := res
	want := `"1"`
	if !cmp.Equal(got, want) {
		t.Errorf("event edit should have saved because values are valid. got = %v, want = %v", got, want)
	}
	confirmEventsRecordValues(t, new_ev_valid, newExpectedJSON)

	confirmEmailTemplatesRecordValues(t, new_ev_valid.EventID, new_ev_valid.EventDescription)
}
