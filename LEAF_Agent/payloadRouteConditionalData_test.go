package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

// TestRouteConditionalData verifies that routeConditionalData calls TakeAction only for
// records returned by FormQuery that also exist in task.Records.
func TestRouteConditionalData(t *testing.T) {
	var called []int

	// Mock server that serves FormQuery results on GET and records TakeAction POSTs.
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			// Return a JSON map of record IDs. The keys are strings because JSON keys must be strings.
			w.Header().Set("Content-Type", "application/json")
			fmt.Fprint(w, `{"1":{}, "2":{}, "3":{}}`)
			return
		}
		if r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/api/formWorkflow/") {
			// Expected path: /api/formWorkflow/{recordID}/apply
			parts := strings.Split(r.URL.Path, "/")
			if len(parts) >= 4 {
				if id, err := strconv.Atoi(parts[3]); err == nil {
					called = append(called, id)
				}
			}
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusNotFound)
	}))
	defer server.Close()

	// Prepare a task that includes only records 1 and 3.
	task := Task{
		SiteURL: server.URL + "/",
		Records: map[int]struct{}{
			1: {},
			3: {},
		},
		StepID: "step1",
	}

	// Payload with no extra query terms – only the mandatory stepID term will be added.
	payload := RouteConditionalDataPayload{
		ActionType: "testAction",
		Query:      query.Query{},
		Comment:    "",
	}

	// Execute the function under test.
	routeConditionalData(&task, payload)

	// Verify that TakeAction was invoked exactly for the intersecting records (1 and 3).
	if len(called) != 2 {
		t.Errorf("expected 2 TakeAction calls, got %d", len(called))
	}
	expected := map[int]bool{1: true, 3: true}
	for _, id := range called {
		if !expected[id] {
			t.Errorf("unexpected record ID called: %d", id)
		}
	}
}

// TestRouteConditionalDataNoMatches verifies behavior when no records match the query
func TestRouteConditionalDataNoMatches(t *testing.T) {
	var called []int

	// Mock server that serves FormQuery results on GET and records TakeAction POSTs.
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			// Return empty JSON map - no matching records
			w.Header().Set("Content-Type", "application/json")
			fmt.Fprint(w, `{}`)
			return
		}
		if r.Method == http.MethodPost && strings.HasPrefix(r.URL.Path, "/api/formWorkflow/") {
			// Expected path: /api/formWorkflow/{recordID}/apply
			parts := strings.Split(r.URL.Path, "/")
			if len(parts) >= 4 {
				if id, err := strconv.Atoi(parts[3]); err == nil {
					called = append(called, id)
				}
			}
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusNotFound)
	}))
	defer server.Close()

	// Prepare a task that includes records 1 and 2.
	task := Task{
		SiteURL: server.URL + "/",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
		StepID: "step1",
	}

	// Payload with no extra query terms – only the mandatory stepID term will be added.
	payload := RouteConditionalDataPayload{
		ActionType: "testAction",
		Query:      query.Query{},
		Comment:    "",
	}

	// Execute the function under test.
	routeConditionalData(&task, payload)

	// Verify that TakeAction was not invoked since no records matched the query
	if len(called) != 0 {
		t.Errorf("expected 0 TakeAction calls, got %d", len(called))
	}
}
