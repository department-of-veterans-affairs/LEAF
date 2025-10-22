package agent

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

// Test that route calls TakeAction once per record.
// A mock HTTP server counts incoming requests; TakeAction is expected to
// perform an HTTP request to the task's SiteURL.
func TestRoute_WithRecords(t *testing.T) {
	callCount := 0
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		callCount++
		w.WriteHeader(http.StatusOK)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			1: {},
			2: {},
			3: {},
		},
	}

	agent.route(&task, RoutePayload{ActionType: "test"})

	expectedCalls := len(task.Records)
	if callCount != expectedCalls {
		t.Errorf("expected %d calls to TakeAction, got %d", expectedCalls, callCount)
	}
}
