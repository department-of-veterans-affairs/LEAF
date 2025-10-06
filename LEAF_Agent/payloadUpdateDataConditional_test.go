package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

// TestUpdateDataConditional_Success tests the successful update of records
func TestUpdateDataConditional_Success(t *testing.T) {
	// Mock server that returns test records and handles update requests
	var updatedRecords []int
	var updatedData map[string]string

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/api/form/query" {
			// Return test records that match the query
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   123,
					S1:       make(query.Data),
				},
				2: {
					RecordID: 2,
					StepID:   123,
					S1:       make(query.Data),
				},
				3: {
					RecordID: 3,
					StepID:   456, // Different stepID, should be filtered out
					S1:       make(query.Data),
				},
			}

			b, _ := json.Marshal(records)
			w.Header().Set("Content-Type", "application/json")
			w.Write(b)
		} else if r.Method == "POST" && r.URL.Path == "/api/form/1" {
			// Handle update for record 1
			r.ParseForm()
			updatedRecords = append(updatedRecords, 1)
			updatedData = make(map[string]string)
			for key, values := range r.Form {
				updatedData[key] = values[0]
			}
			w.WriteHeader(http.StatusOK)
		} else if r.Method == "POST" && r.URL.Path == "/api/form/2" {
			// Handle update for record 2
			r.ParseForm()
			updatedRecords = append(updatedRecords, 2)
			updatedData = make(map[string]string)
			for key, values := range r.Form {
				updatedData[key] = values[0]
			}
			w.WriteHeader(http.StatusOK)
		}
	}))

	task := Task{
		SiteURL: ts.URL,
		StepID:  "123",
		Records: map[int]struct{}{
			1: {},
			2: {},
			3: {},
		},
	}

	payload := UpdateDataConditionalPayload{
		Query: query.Query{
			Terms: []query.Term{
				{
					ID:       "data",
					Operator: "=",
					Match:    "test",
				},
			},
		},
		WriteIndicatorID: 42,
		Content:          "updated content",
	}

	updateDataConditional(&task, payload)

	// Verify that records 1 and 2 were updated (they match stepID)
	if len(updatedRecords) != 2 {
		t.Errorf("Expected 2 records to be updated, got %d", len(updatedRecords))
	}

	// Verify the updated data
	if updatedData["42"] != "updated content" {
		t.Errorf("Expected content 'updated content', got '%s'", updatedData["42"])
	}

	// Verify that record 3 was not updated (different stepID)
	found := false
	for _, id := range updatedRecords {
		if id == 3 {
			found = true
			break
		}
	}
	if found {
		t.Error("Record 3 should not have been updated (different stepID)")
	}
}

// TestUpdateDataConditional_NoMatchingRecords tests when no records match the query
func TestUpdateDataConditional_NoMatchingRecords(t *testing.T) {
	updateRequestCount := 0

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/api/form/query" {
			// Return empty response
			records := query.Response{}
			b, _ := json.Marshal(records)
			w.Header().Set("Content-Type", "application/json")
			w.Write(b)
		} else if r.Method == "POST" {
			// Count any update requests
			updateRequestCount++
			t.Errorf("Unexpected update request made to %s when no records match the query", r.URL.Path)
		}
	}))

	task := Task{
		SiteURL: ts.URL,
		StepID:  "123",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	payload := UpdateDataConditionalPayload{
		Query: query.Query{
			Terms: []query.Term{
				{
					ID:       "data",
					Operator: "=",
					Match:    "nonexistent",
				},
			},
		},
		WriteIndicatorID: 42,
		Content:          "updated content",
	}

	updateDataConditional(&task, payload)

	// No errors should occur and no updates should be made
	if len(task.Errors) > 0 {
		t.Errorf("Expected no errors, got %d errors", len(task.Errors))
	}

	// Verify that no update requests were made
	if updateRequestCount != 0 {
		t.Errorf("Expected 0 update requests to be made, got %d", updateRequestCount)
	}
}

// TestUpdateDataConditional_QueryError tests handling of query errors
func TestUpdateDataConditional_QueryError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/api/form/query" {
			// Return server error
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Database error"))
		}
	}))

	task := Task{
		SiteURL: ts.URL,
		StepID:  "123",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataConditionalPayload{
		Query: query.Query{
			Terms: []query.Term{
				{
					ID:       "data",
					Operator: "=",
					Match:    "test",
				},
			},
		},
		WriteIndicatorID: 42,
		Content:          "updated content",
	}

	updateDataConditional(&task, payload)

	// Should have an error logged
	if len(task.Errors) == 0 {
		t.Error("Expected an error to be logged")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected records to be cleared, got %d records", len(task.Records))
	}
}

// TestUpdateDataConditional_UpdateError tests handling of update errors
func TestUpdateDataConditional_UpdateError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/api/form/query" {
			// Return test records
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   123,
					S1:       make(query.Data),
				},
			}
			b, _ := json.Marshal(records)
			w.Header().Set("Content-Type", "application/json")
			w.Write(b)
		} else if r.Method == "POST" && r.URL.Path == "/api/form/1" {
			// Return error for update
			w.WriteHeader(http.StatusBadRequest)
			w.Write([]byte("Update failed"))
		}
	}))

	task := Task{
		SiteURL: ts.URL,
		StepID:  "123",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataConditionalPayload{
		Query: query.Query{
			Terms: []query.Term{
				{
					ID:       "data",
					Operator: "=",
					Match:    "test",
				},
			},
		},
		WriteIndicatorID: 42,
		Content:          "updated content",
	}

	updateDataConditional(&task, payload)

	// Should have an error logged
	if len(task.Errors) == 0 {
		t.Error("Expected an error to be logged")
	}

	// Record 1 should be removed from the working set due to error
	if _, exists := task.Records[1]; exists {
		t.Error("Record 1 should have been removed from working set due to error")
	}
}

// TestUpdateDataConditional_AllowedTerms tests that only allowed query terms are used
func TestUpdateDataConditional_AllowedTerms(t *testing.T) {
	var receivedQuery string

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/api/form/query" {
			// Capture the query parameter
			receivedQuery = r.URL.Query().Get("q")

			// Return empty response since we're just testing the query construction
			records := query.Response{}
			b, _ := json.Marshal(records)
			w.Header().Set("Content-Type", "application/json")
			w.Write(b)
		}
	}))

	task := Task{
		SiteURL: ts.URL,
		StepID:  "123",
		Records: map[int]struct{}{},
	}

	payload := UpdateDataConditionalPayload{
		Query: query.Query{
			Terms: []query.Term{
				{
					ID:       "data", // Allowed
					Operator: "=",
					Match:    "test1",
				},
				{
					ID:       "serviceID", // Allowed
					Operator: "=",
					Match:    "test2",
				},
				{
					ID:       "forbidden", // Not allowed
					Operator: "=",
					Match:    "test3",
				},
				{
					ID:       "title", // Allowed
					Operator: "=",
					Match:    "test4",
				},
			},
		},
		WriteIndicatorID: 42,
		Content:          "updated content",
	}

	updateDataConditional(&task, payload)

	// Parse the received query to verify it contains only allowed terms
	var parsedQuery query.Query
	json.Unmarshal([]byte(receivedQuery), &parsedQuery)

	// Should have stepID term + allowed terms (data, serviceID, title) = 4 terms total
	expectedTermCount := 4 // stepID + data + serviceID + title
	if len(parsedQuery.Terms) != expectedTermCount {
		t.Errorf("Expected %d terms in query, got %d", expectedTermCount, len(parsedQuery.Terms))
	}

	// Verify forbidden term is not present
	for _, term := range parsedQuery.Terms {
		if term.ID == "forbidden" {
			t.Error("Forbidden term 'forbidden' should not be present in query")
		}
	}

	// Verify allowed terms are present
	allowedTerms := map[string]bool{
		"stepID":    false,
		"data":      false,
		"serviceID": false,
		"title":     false,
	}

	for _, term := range parsedQuery.Terms {
		if _, exists := allowedTerms[term.ID]; exists {
			allowedTerms[term.ID] = true
		}
	}

	for termID, found := range allowedTerms {
		if !found {
			t.Errorf("Expected allowed term '%s' to be present in query", termID)
		}
	}
}

// TestUpdateDataConditional_RecordNotInWorkingSet tests that records not in the working set are ignored
func TestUpdateDataConditional_RecordNotInWorkingSet(t *testing.T) {
	var updatedRecords []int

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/api/form/query" {
			// Return records where only record 1 is in the working set
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   123,
					S1:       make(query.Data),
				},
				2: {
					RecordID: 2,
					StepID:   123,
					S1:       make(query.Data),
				},
			}
			b, _ := json.Marshal(records)
			w.Header().Set("Content-Type", "application/json")
			w.Write(b)
		} else if r.Method == "POST" {
			// Capture which records are being updated
			recordID, _ := strconv.Atoi(r.URL.Path[len("/api/form/"):])
			updatedRecords = append(updatedRecords, recordID)
			w.WriteHeader(http.StatusOK)
		}
	}))

	task := Task{
		SiteURL: ts.URL,
		StepID:  "123",
		Records: map[int]struct{}{
			1: {}, // Only record 1 is in the working set
			// Record 2 is not in the working set
		},
	}

	payload := UpdateDataConditionalPayload{
		Query: query.Query{
			Terms: []query.Term{
				{
					ID:       "data",
					Operator: "=",
					Match:    "test",
				},
			},
		},
		WriteIndicatorID: 42,
		Content:          "updated content",
	}

	updateDataConditional(&task, payload)

	// Only record 1 should be updated
	if len(updatedRecords) != 1 {
		t.Errorf("Expected 1 record to be updated, got %d", len(updatedRecords))
	}

	if len(updatedRecords) > 0 && updatedRecords[0] != 1 {
		t.Errorf("Expected record 1 to be updated, got record %d", updatedRecords[0])
	}
}

// TestUpdateDataConditional_EmptyWorkingSet tests behavior with empty working set
func TestUpdateDataConditional_EmptyWorkingSet(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method == "GET" && r.URL.Path == "/api/form/query" {
			// Return records
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   123,
					S1:       make(query.Data),
				},
			}
			b, _ := json.Marshal(records)
			w.Header().Set("Content-Type", "application/json")
			w.Write(b)
		} else if r.Method == "POST" {
			t.Error("No update requests should be made when working set is empty")
		}
	}))

	task := Task{
		SiteURL: ts.URL,
		StepID:  "123",
		Records: map[int]struct{}{}, // Empty working set
	}

	payload := UpdateDataConditionalPayload{
		Query: query.Query{
			Terms: []query.Term{
				{
					ID:       "data",
					Operator: "=",
					Match:    "test",
				},
			},
		},
		WriteIndicatorID: 42,
		Content:          "updated content",
	}

	updateDataConditional(&task, payload)

	// No errors should occur
	if len(task.Errors) > 0 {
		t.Errorf("Expected no errors, got %d errors", len(task.Errors))
	}
}
