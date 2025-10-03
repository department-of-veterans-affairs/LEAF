package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

func Test_RouteActionHistoryTally(t *testing.T) {
	callCount := 0

	// Mock response with action history data
	records := query.Response{
		1: { // Record with sufficient action count (2 approve actions)
			ActionHistory: []query.ActionHistory{
				{
					ActionType: "approve",
					StepID:     1,
				},
				{
					ActionType: "approve",
					StepID:     1,
				},
				{
					ActionType: "reject",
					StepID:     1,
				},
			},
		},
		2: { // Record with insufficient action count (only 1 approve action)
			ActionHistory: []query.ActionHistory{
				{
					ActionType: "approve",
					StepID:     1,
				},
			},
		},
		3: { // Record with no matching actions
			ActionHistory: []query.ActionHistory{
				{
					ActionType: "reject",
					StepID:     1,
				},
			},
		},
	}

	// Single mock server that serves the query response on GET
	// and counts POST requests (which correspond to TakeAction calls).
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodPost {
			// Count TakeAction invocation
			callCount++
			w.WriteHeader(http.StatusOK)
			return
		}
		// Serve the mocked query response
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			1: {}, // should trigger TakeAction (2 approve actions)
			2: {}, // should NOT trigger (only 1 approve)
			3: {}, // should NOT trigger (no approve)
		},
		StepID: "1",
	}

	payload := RouteActionHistoryTallyPayload{
		ActionType:      "send_to_supervisor",
		ActionTypeTaken: "approve",
		MinimumCount:    2,
		Comment:         "Test comment",
		StepID:          1,
	}

	routeActionHistoryTally(&task, payload)

	// Expect exactly one TakeAction call (for record 1)
	expectedCalls := 1
	if callCount != expectedCalls {
		t.Errorf("expected %d calls to TakeAction, got %d", expectedCalls, callCount)
	}
}

// Test that empty records do not cause errors and result in zero TakeAction calls.
func Test_RouteActionHistoryTally_EmptyRecords_NoError(t *testing.T) {
	callCount := 0

	// Empty response for the query
	records := query.Response{}

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodPost {
			callCount++
			w.WriteHeader(http.StatusOK)
			return
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{},
		StepID:  "1",
	}

	payload := RouteActionHistoryTallyPayload{
		ActionType:      "send_to_supervisor",
		ActionTypeTaken: "approve",
		MinimumCount:    1,
		Comment:         "Test comment",
		StepID:          1,
	}

	routeActionHistoryTally(&task, payload)

	// No TakeAction should have been invoked
	expectedCalls := 0
	if callCount != expectedCalls {
		t.Errorf("expected %d calls to TakeAction, got %d", expectedCalls, callCount)
	}
}

// Test that records not present in the task's Records map are skipped and do not trigger TakeAction.
func Test_RouteActionHistoryTally_SkipNonSetRecords(t *testing.T) {
	callCount := 0

	// Mock response containing a record that meets the action count criteria,
	// but the task's Records set will be empty, so it should be ignored.
	records := query.Response{
		1: {
			ActionHistory: []query.ActionHistory{
				{
					ActionType: "approve",
					StepID:     1,
				},
				{
					ActionType: "approve",
					StepID:     1,
				},
			},
		},
	}

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodPost {
			callCount++
			w.WriteHeader(http.StatusOK)
			return
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			// Intentionally empty – record 1 is not part of the set
		},
		StepID: "1",
	}

	payload := RouteActionHistoryTallyPayload{
		ActionType:      "send_to_supervisor",
		ActionTypeTaken: "approve",
		MinimumCount:    2,
		Comment:         "Test comment",
		StepID:          1,
	}

	routeActionHistoryTally(&task, payload)

	// No TakeAction should have been invoked because the record is not in the set
	expectedCalls := 0
	if callCount != expectedCalls {
		t.Errorf("expected %d calls to TakeAction, got %d", expectedCalls, callCount)
	}
}
