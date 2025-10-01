package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

// Hold records if they're less than 20 seconds old
func Test_HoldForDuration(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		currTime := int(time.Now().Unix())

		records := query.Response{
			1: { // Record should be held since it's under 20 seconds old
				Submitted: 1,
				StepFulfillmentOnly: []query.StepFulfillment{
					{
						StepID: 1,
						Time:   currTime - 10,
					},
				},
			},
			2: { // Record without stepFulfillment data
				Submitted: currTime - 10,
			},
			3: { // Record should be not held since it's over 20 seconds old
				Submitted: 1,
				StepFulfillmentOnly: []query.StepFulfillment{
					{
						StepID: 1,
						Time:   currTime - 30,
					},
				},
			},
		}

		b, _ := json.Marshal(records)
		w.Write(b)
	}))

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			1: {},
			2: {},
			3: {},
		},
	}

	holdForDuration(&task, HoldForDurationPayload{SecondsToHold: 20})

	if _, exists := task.Records[1]; exists {
		t.Errorf("Record 1 exists got = %v, want %v", exists, false)
	}
	if _, exists := task.Records[2]; exists {
		t.Errorf("Record 2 exists got = %v, want %v", exists, false)
	}
	if _, exists := task.Records[3]; !exists {
		t.Errorf("Record 3 exists got = %v, want %v", exists, true)
	}
}
