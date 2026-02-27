package agent

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form"
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

func Test_UpdateTitleLLMLabel_Success(t *testing.T) {
	// Mock server for form query
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "Test data for indicator 1",
						"id2": "Test data for indicator 2",
					},
				},
				2: {
					RecordID: 2,
					StepID:   1,
					S1: query.Data{
						"id1": "Another test data",
						"id2": "",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Indicator 1", ShortLabel: "Ind1"},
				{IndicatorID: 2, Name: "Indicator 2", ShortLabel: "Ind2"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/1/title") {
			w.WriteHeader(http.StatusOK)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/2/title") {
			w.WriteHeader(http.StatusOK)
			return
		}
	}))
	defer ts.Close()

	// Mock LLM server
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		response := LLMResponse{
			Choices: []choice{
				{
					Message: Message{
						Content: "Test Label",
					},
				},
			},
		}
		b, _ := json.Marshal(response)
		w.Write(b)
	}))
	defer llmTs.Close()

	// Set LLM URL for testing
	agent.llmCategorizationURL = llmTs.URL
	agent.llmApiKey = "test-key"

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1, 2},
		Context:          "Test context",
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Check that no errors occurred
	if len(task.Errors) > 0 {
		t.Errorf("Unexpected errors: %v", task.Errors)
	}

	// Check that records are still in the set (no errors occurred)
	if _, exists := task.Records[1]; !exists {
		t.Error("Record 1 should still exist in the set")
	}
	if _, exists := task.Records[2]; !exists {
		t.Error("Record 2 should still exist in the set")
	}
}

func Test_UpdateTitleLLMLabel_EmptyRecords(t *testing.T) {
	queryCalled := false
	titleUpdateCalled := false

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			queryCalled = true
			records := query.Response{}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		// This should never be called since there are no records
		if strings.Contains(r.URL.Path, "api/form/") && strings.Contains(r.URL.Path, "/title") {
			titleUpdateCalled = true
			t.Errorf("Unexpected title update call: %s", r.URL.Path)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1, 2},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Verify that query was called but no title updates were made
	if !queryCalled {
		t.Error("Expected form query to be called")
	}

	if titleUpdateCalled {
		t.Error("Expected no title updates to be made when there are no records")
	}

	// Should exit early with no errors
	if len(task.Errors) > 0 {
		t.Errorf("Unexpected errors: %v", task.Errors)
	}

	// Verify that the task records remain unchanged
	if len(task.Records) != 1 {
		t.Errorf("Expected 1 record in task, got %d", len(task.Records))
	}

	if _, exists := task.Records[1]; !exists {
		t.Error("Record 1 should still exist in the task")
	}
}

func Test_UpdateTitleLLMLabel_RecordNotInSet(t *testing.T) {
	queryCalled := false
	indicatorListCalled := false
	titleUpdateCalled := false

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			queryCalled = true
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "Test data",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicatorListCalled = true
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Indicator 1"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		// This should never be called since record 1 is not in the task.Records set
		if strings.Contains(r.URL.Path, "api/form/") && strings.Contains(r.URL.Path, "/title") {
			titleUpdateCalled = true
			t.Errorf("Unexpected title update call: %s", r.URL.Path)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}))
	defer ts.Close()

	// Mock LLM server to verify no LLM calls are made
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Errorf("Unexpected LLM call made - no LLM calls should be made when record is not in set")
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Unexpected LLM call"))
	}))
	defer llmTs.Close()

	// Set LLM URL for testing
	agent.llmCategorizationURL = llmTs.URL
	agent.llmApiKey = "test-key"

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			2: {}, // Record 2 is in set, but query returns record 1
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Verify that query and indicator list were called (initial setup)
	if !queryCalled {
		t.Error("Expected form query to be called")
	}
	if !indicatorListCalled {
		t.Error("Expected indicator list to be called")
	}

	// Verify that no title updates were made
	if titleUpdateCalled {
		t.Error("Expected no title updates to be made when record is not in task.Records set")
	}

	// Should not process record 1 since it's not in the task.Records set
	if len(task.Errors) > 0 {
		t.Errorf("Unexpected errors: %v", task.Errors)
	}

	// Verify that the task records remain unchanged
	if len(task.Records) != 1 {
		t.Errorf("Expected 1 record in task, got %d", len(task.Records))
	}

	if _, exists := task.Records[2]; !exists {
		t.Error("Record 2 should still exist in the task")
	}

	// Verify that record 1 was never added to the task
	if _, exists := task.Records[1]; exists {
		t.Error("Record 1 should not exist in the task as it was not processed")
	}
}

func Test_UpdateTitleLLMLabel_EmptyInput(t *testing.T) {
	queryCalled := false
	indicatorListCalled := false
	titleUpdateCalled := false

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			queryCalled = true
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "", // Empty data
						"id2": "", // Empty data
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicatorListCalled = true
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Indicator 1"},
				{IndicatorID: 2, Name: "Indicator 2"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		// This should never be called since input is empty
		if strings.Contains(r.URL.Path, "api/form/") && strings.Contains(r.URL.Path, "/title") {
			titleUpdateCalled = true
			t.Errorf("Unexpected title update call: %s", r.URL.Path)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}))
	defer ts.Close()

	// Mock LLM server to verify no LLM calls are made
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Errorf("Unexpected LLM call made - no LLM calls should be made when input is empty")
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Unexpected LLM call"))
	}))
	defer llmTs.Close()

	// Set LLM URL for testing
	agent.llmCategorizationURL = llmTs.URL
	agent.llmApiKey = "test-key"

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1, 2},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Verify that query and indicator list were called (initial setup)
	if !queryCalled {
		t.Error("Expected form query to be called")
	}
	if !indicatorListCalled {
		t.Error("Expected indicator list to be called")
	}

	// Verify that no title updates were made
	if titleUpdateCalled {
		t.Error("Expected no title updates to be made when input is empty")
	}

	// Should skip record due to empty input
	if len(task.Errors) > 0 {
		t.Errorf("Unexpected errors: %v", task.Errors)
	}

	// Verify that the task records remain unchanged
	if len(task.Records) != 1 {
		t.Errorf("Expected 1 record in task, got %d", len(task.Records))
	}

	if _, exists := task.Records[1]; !exists {
		t.Error("Record 1 should still exist in the task")
	}
}

func Test_UpdateTitleLLMLabel_FormQueryError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Query error"))
			return
		}
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Should have an error
	if len(task.Errors) == 0 {
		t.Error("Expected error but got none")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Error("Expected records to be cleared due to error")
	}
}

func Test_UpdateTitleLLMLabel_IndicatorMapError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "Test data",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Indicator error"))
			return
		}
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Should have an error
	if len(task.Errors) == 0 {
		t.Error("Expected error but got none")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Error("Expected records to be cleared due to error")
	}
}

func Test_UpdateTitleLLMLabel_LLMError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "Test data",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Indicator 1"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}
	}))
	defer ts.Close()

	// Mock LLM server that returns an error
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("LLM error"))
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL
	agent.llmApiKey = "test-key"

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Should have an error
	if len(task.Errors) == 0 {
		t.Error("Expected error but got none")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Error("Expected records to be cleared due to error")
	}
}

func Test_UpdateTitleLLMLabel_LLMResponseTooLong(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "Test data",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Indicator 1"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}
	}))
	defer ts.Close()

	// Mock LLM server that returns a response longer than 50 characters
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		response := LLMResponse{
			Choices: []choice{
				{
					Message: Message{
						Content: "This is a very long label that exceeds the 50 character limit",
					},
				},
			},
		}
		b, _ := json.Marshal(response)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL
	agent.llmApiKey = "test-key"

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Should have an error about response length
	if len(task.Errors) == 0 {
		t.Error("Expected error but got none")
	}

	// Record 1 should be removed due to error
	if _, exists := task.Records[1]; exists {
		t.Error("Record 1 should be removed due to error")
	}
}

func Test_UpdateTitleLLMLabel_UpdateTitleError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "Test data",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Indicator 1"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/1/title") {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Update title error"))
			return
		}
	}))
	defer ts.Close()

	// Mock LLM server
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		response := LLMResponse{
			Choices: []choice{
				{
					Message: Message{
						Content: "Test Label",
					},
				},
			},
		}
		b, _ := json.Marshal(response)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL
	agent.llmApiKey = "test-key"

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Should have an error
	if len(task.Errors) == 0 {
		t.Error("Expected error but got none")
	}

	// Records should be cleared due to error (recordID 0 passed to HandleError)
	if len(task.Records) != 0 {
		t.Error("Expected records to be cleared due to error")
	}
}

func Test_UpdateTitleLLMLabel_HTMLSanitization(t *testing.T) {
	var actualTitle string

	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					RecordID: 1,
					StepID:   1,
					S1: query.Data{
						"id1": "Test data",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Indicator 1"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		if strings.Contains(r.URL.Path, "api/form/1/title") {
			// Capture the actual title being sent
			r.ParseForm()
			actualTitle = r.FormValue("title")
			w.WriteHeader(http.StatusOK)
			return
		}
	}))
	defer ts.Close()

	// Mock LLM server that returns HTML content
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		response := LLMResponse{
			Choices: []choice{
				{
					Message: Message{
						Content: "<script>alert('xss')</script>Clean Label",
					},
				},
			},
		}
		b, _ := json.Marshal(response)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL
	agent.llmApiKey = "test-key"

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateTitleLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
	}

	agent.updateTitleLLMLabel(&task, payload)

	// Should complete successfully with sanitized content
	if len(task.Errors) > 0 {
		t.Errorf("Unexpected errors: %v", task.Errors)
	}

	// Verify that HTML tags were sanitized
	expectedSanitizedTitle := "Clean Label"
	if actualTitle != expectedSanitizedTitle {
		t.Errorf("Expected sanitized title '%s', but got '%s'", expectedSanitizedTitle, actualTitle)
	}

	// Verify that no HTML tags remain in the sanitized title
	if strings.Contains(actualTitle, "<script>") || strings.Contains(actualTitle, "</script>") {
		t.Errorf("HTML tags were not properly sanitized. Title still contains HTML: %s", actualTitle)
	}
}
