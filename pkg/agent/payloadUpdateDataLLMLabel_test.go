package agent

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form"
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

// TestUpdateDataLLMLabel_Success tests the successful execution of updateDataLLMLabel
func TestUpdateDataLLMLabel_Success(t *testing.T) {
	// Mock server for form query endpoint
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 2, Name: "Field2", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "text"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		// Check if this is a form update request
		if strings.Contains(r.URL.Path, "/api/form/") && r.Method == "POST" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Otherwise, it's a query request
		records := query.Response{
			1: {
				RecordID: 1,
				StepID:   1,
				S1: map[string]string{
					"id1": "This is test data for record 1",
					"id2": "Additional test data",
				},
			},
			2: {
				RecordID: 2,
				StepID:   1,
				S1: map[string]string{
					"id1": "This is test data for record 2",
					"id2": "More test content",
				},
			},
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	// Mock server for LLM endpoint
	llmServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
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
	defer llmServer.Close()

	// Set up task
	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	// Override global variables for testing
	originalLLMURL := agent.llmCategorizationURL
	originalLLMKey := agent.llmApiKey
	agent.llmCategorizationURL = llmServer.URL
	agent.llmApiKey = "test-key"
	defer func() {
		agent.llmCategorizationURL = originalLLMURL
		agent.llmApiKey = originalLLMKey
	}()

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1, 2},
		WriteIndicatorID: 3,
		Context:          "Test context",
	}

	agent.updateDataLLMLabel(&task, payload)

	// Check that no errors occurred
	if len(task.Errors) > 0 {
		t.Errorf("Unexpected errors: %v", task.Errors)
	}
}

// TestUpdateDataLLMLabel_EmptyRecords tests handling when no records are found
func TestUpdateDataLLMLabel_EmptyRecords(t *testing.T) {
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 2, Name: "Field2", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "text"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		// Return empty records
		records := query.Response{}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{},
	}

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1, 2},
		WriteIndicatorID: 3,
	}

	agent.updateDataLLMLabel(&task, payload)

	// Should have no errors and no records processed
	if len(task.Errors) > 0 {
		t.Errorf("Unexpected errors: %v", task.Errors)
	}
}

// TestUpdateDataLLMLabel_InvalidWriteIndicator tests error when write indicator is not text/textarea
func TestUpdateDataLLMLabel_InvalidWriteIndicator(t *testing.T) {
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "number"}, // Invalid format
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		records := query.Response{
			1: {
				RecordID: 1,
				StepID:   1,
				S1: map[string]string{
					"id1": "Test data",
				},
			},
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
		WriteIndicatorID: 3, // This has invalid format
	}

	agent.updateDataLLMLabel(&task, payload)

	// Should have an error about invalid format
	if len(task.Errors) == 0 {
		t.Error("Expected error about invalid indicator format, but got none")
	}

	expectedError := "indicator ID 3 does not reference a text or textarea field"
	if !strings.Contains(task.Errors[0].Error, expectedError) {
		t.Errorf("Expected error containing '%s', got '%s'", expectedError, task.Errors[0].Error)
	}
}

// TestUpdateDataLLMLabel_EmptyInputData tests skipping records with empty input data
func TestUpdateDataLLMLabel_EmptyInputData(t *testing.T) {
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 2, Name: "Field2", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "text"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		// Check if this is a form update request
		if strings.Contains(r.URL.Path, "/api/form/") && r.Method == "POST" {
			w.WriteHeader(http.StatusOK)
			return
		}

		records := query.Response{
			1: {
				RecordID: 1,
				StepID:   1,
				S1: map[string]string{
					"id1": "", // Empty data
					"id2": "", // Empty data
				},
			},
			2: {
				RecordID: 2,
				StepID:   1,
				S1: map[string]string{
					"id1": "Non-empty data",
					"id2": "More data",
				},
			},
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	// Mock LLM server to track calls
	llmCallCount := 0
	llmServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		llmCallCount++
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
	defer llmServer.Close()

	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	// Override global variables for testing
	originalLLMURL := agent.llmCategorizationURL
	originalLLMKey := agent.llmApiKey
	agent.llmCategorizationURL = llmServer.URL
	agent.llmApiKey = "test-key"
	defer func() {
		agent.llmCategorizationURL = originalLLMURL
		agent.llmApiKey = originalLLMKey
	}()

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1, 2},
		WriteIndicatorID: 3,
	}

	agent.updateDataLLMLabel(&task, payload)

	// LLM should only be called once for record 2 (record 1 should be skipped)
	if llmCallCount != 1 {
		t.Errorf("Expected 1 LLM call, got %d", llmCallCount)
	}
}

// TestUpdateDataLLMLabel_LLMError tests handling of LLM API errors
func TestUpdateDataLLMLabel_LLMError(t *testing.T) {
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "text"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		records := query.Response{
			1: {
				RecordID: 1,
				StepID:   1,
				S1: map[string]string{
					"id1": "Test data",
				},
			},
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	// Mock LLM server to return an error
	llmServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("LLM API error"))
	}))
	defer llmServer.Close()

	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	// Override global variables for testing
	originalLLMURL := agent.llmCategorizationURL
	originalLLMKey := agent.llmApiKey
	agent.llmCategorizationURL = llmServer.URL
	agent.llmApiKey = "test-key"
	defer func() {
		agent.llmCategorizationURL = originalLLMURL
		agent.llmApiKey = originalLLMKey
	}()

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
		WriteIndicatorID: 3,
	}

	agent.updateDataLLMLabel(&task, payload)

	// Should have an error from the LLM call
	if len(task.Errors) == 0 {
		t.Error("Expected error from LLM call, but got none")
	}

	if !strings.Contains(task.Errors[0].Error, "GetLLMResponse") {
		t.Errorf("Expected error containing 'GetLLMResponse', got '%s'", task.Errors[0].Error)
	}
}

// TestUpdateDataLLMLabel_ResponseTooLong tests handling of LLM responses that exceed 50 characters
func TestUpdateDataLLMLabel_ResponseTooLong(t *testing.T) {
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "text"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		records := query.Response{
			1: {
				RecordID: 1,
				StepID:   1,
				S1: map[string]string{
					"id1": "Test data",
				},
			},
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	// Mock LLM server to return a response that's too long
	llmServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		response := LLMResponse{
			Choices: []choice{
				{
					Message: Message{
						Content: "This is a very long response that exceeds the 50 character limit",
					},
				},
			},
		}
		b, _ := json.Marshal(response)
		w.Write(b)
	}))
	defer llmServer.Close()

	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	// Override global variables for testing
	originalLLMURL := agent.llmCategorizationURL
	originalLLMKey := agent.llmApiKey
	agent.llmCategorizationURL = llmServer.URL
	agent.llmApiKey = "test-key"
	defer func() {
		agent.llmCategorizationURL = originalLLMURL
		agent.llmApiKey = originalLLMKey
	}()

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
		WriteIndicatorID: 3,
	}

	agent.updateDataLLMLabel(&task, payload)

	// Should have an error about response being too long
	if len(task.Errors) == 0 {
		t.Error("Expected error about response being too long, but got none")
	}

	if !strings.Contains(task.Errors[0].Error, "exceeds 50 character constraint") {
		t.Errorf("Expected error about 50 character constraint, got '%s'", task.Errors[0].Error)
	}
}

// TestUpdateDataLLMLabel_WithContext tests that context is properly included in the prompt
func TestUpdateDataLLMLabel_WithContext(t *testing.T) {
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "text"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		// Check if this is a form update request
		if strings.Contains(r.URL.Path, "/api/form/") && r.Method == "POST" {
			w.WriteHeader(http.StatusOK)
			return
		}

		records := query.Response{
			1: {
				RecordID: 1,
				StepID:   1,
				S1: map[string]string{
					"id1": "Test data",
				},
			},
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	// Capture the LLM request to verify context is included
	var capturedConfig Completions
	llmServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Decode the request to capture the config
		var config Completions
		json.NewDecoder(r.Body).Decode(&config)
		capturedConfig = config

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
	defer llmServer.Close()

	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	// Override global variables for testing
	originalLLMURL := agent.llmCategorizationURL
	originalLLMKey := agent.llmApiKey
	agent.llmCategorizationURL = llmServer.URL
	agent.llmApiKey = "test-key"
	defer func() {
		agent.llmCategorizationURL = originalLLMURL
		agent.llmApiKey = originalLLMKey
	}()

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
		WriteIndicatorID: 3,
		Context:          "This is custom context",
	}

	agent.updateDataLLMLabel(&task, payload)

	// Verify that context was included in the first message
	if len(capturedConfig.Messages) < 2 {
		t.Error("Expected at least 2 messages in LLM config")
		return
	}

	expectedContext := "This is custom context\nLabel the following text. The label must be less than 50 characters."
	if capturedConfig.Messages[0].Content != expectedContext {
		t.Errorf("Expected context '%s', got '%s'", expectedContext, capturedConfig.Messages[0].Content)
	}
}

// TestUpdateDataLLMLabel_RecordNotInSet tests that records not in the current set are skipped
func TestUpdateDataLLMLabel_RecordNotInSet(t *testing.T) {
	queryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Check if this is an indicator list request
		if strings.Contains(r.URL.Path, "indicator/list") {
			indicators := []form.Indicator{
				{IndicatorID: 1, Name: "Field1", Format: "text"},
				{IndicatorID: 3, Name: "LabelField", Format: "text"},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
			return
		}

		// Check if this is a form update request
		if strings.Contains(r.URL.Path, "/api/form/") && r.Method == "POST" {
			// Parse the record ID from the URL
			pathParts := strings.Split(r.URL.Path, "/")
			recordID, _ := strconv.Atoi(pathParts[len(pathParts)-1])

			// Only record 1 should be updated (record 2 should be skipped)
			if recordID != 1 {
				t.Errorf("Unexpected update request for record %d, only record 1 should be updated", recordID)
			}
			w.WriteHeader(http.StatusOK)
			return
		}

		records := query.Response{
			1: {
				RecordID: 1,
				StepID:   1,
				S1: map[string]string{
					"id1": "Test data for record 1",
				},
			},
			2: {
				RecordID: 2,
				StepID:   1,
				S1: map[string]string{
					"id1": "Test data for record 2",
				},
			},
		}
		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer queryServer.Close()

	// Track LLM calls
	llmCallCount := 0
	llmServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		llmCallCount++
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
	defer llmServer.Close()

	// Only record 1 is in the current set
	task := Task{
		SiteURL: queryServer.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {}, // Only record 1
		},
	}

	// Override global variables for testing
	originalLLMURL := agent.llmCategorizationURL
	originalLLMKey := agent.llmApiKey
	agent.llmCategorizationURL = llmServer.URL
	agent.llmApiKey = "test-key"
	defer func() {
		agent.llmCategorizationURL = originalLLMURL
		agent.llmApiKey = originalLLMKey
	}()

	payload := UpdateDataLLMLabelPayload{
		ReadIndicatorIDs: []int{1},
		WriteIndicatorID: 3,
	}

	agent.updateDataLLMLabel(&task, payload)

	// LLM should only be called once for record 1 (record 2 should be skipped)
	if llmCallCount != 1 {
		t.Errorf("Expected 1 LLM call, got %d", llmCallCount)
	}
}
