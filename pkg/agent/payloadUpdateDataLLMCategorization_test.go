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

func Test_UpdateDataLLMCategorization_Success(t *testing.T) {
	// Mock server for form query
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			// Return mock records
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "This is a test record about technical support",
						"id101": "High priority issue",
					},
				},
				2: {
					S1: map[string]string{
						"id100": "User request for account access",
						"id101": "Medium priority",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			// Return mock indicators
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   101,
					Name:          "Priority",
					ShortLabel:    "Priority",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "radio\nTechnical\nAccount\nBilling\nOther",
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/") && r.Method == "POST" {
			// Mock successful record update
			w.WriteHeader(http.StatusOK)
		}
	}))
	defer ts.Close()

	// Mock LLM server
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Return mock LLM response
		llmResponse := response{
			Choices: []choice{
				{
					Message: Message{
						Content: "Technical",
					},
				},
			},
		}
		b, _ := json.Marshal(llmResponse)
		w.Write(b)
	}))
	defer llmTs.Close()

	// Set LLM URL for testing
	agent.llmCategorizationURL = llmTs.URL

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100, 101},
		WriteIndicatorID: 200,
		Context:          "Please categorize the following support requests:",
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Verify no errors occurred
	if len(task.Errors) != 0 {
		t.Errorf("Expected no errors, got %d errors: %v", len(task.Errors), task.Errors)
	}

	// Verify records are still in the set (successful processing)
	if len(task.Records) != 2 {
		t.Errorf("Expected 2 records in set, got %d", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_NoRecords(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			// Return empty records
			records := query.Response{}
			b, _ := json.Marshal(records)
			w.Write(b)
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

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should exit early with no errors
	if len(task.Errors) != 0 {
		t.Errorf("Expected no errors for empty records, got %d errors: %v", len(task.Errors), task.Errors)
	}
}

func Test_UpdateDataLLMCategorization_FormQueryError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Database error"))
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

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have an error
	if len(task.Errors) == 0 {
		t.Error("Expected error for FormQuery failure, got none")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected records to be cleared due to error, got %d records", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_GetIndicatorMapError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "Test content",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Indicator error"))
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

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have an error
	if len(task.Errors) == 0 {
		t.Error("Expected error for GetIndicatorMap failure, got none")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected records to be cleared due to error, got %d records", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_NoFormatOptions(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "Test content",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			// Return indicator with no format options
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "text", // No format options
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
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

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have an error about no format options
	if len(task.Errors) == 0 {
		t.Error("Expected error for no format options, got none")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected records to be cleared due to error, got %d records", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_LLMError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "Test content",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "radio\nTechnical\nAccount\nBilling\nOther",
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		}
	}))
	defer ts.Close()

	// Mock LLM server that returns an error
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("LLM service unavailable"))
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have an error from LLM
	if len(task.Errors) == 0 {
		t.Error("Expected error for LLM failure, got none")
	}

	// Records should be cleared due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected records to be cleared due to error, got %d records", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_InvalidLLMResponse(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "Test content",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "radio\nTechnical\nAccount\nBilling\nOther",
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/") && r.Method == "POST" {
			w.WriteHeader(http.StatusOK)
		}
	}))
	defer ts.Close()

	// Mock LLM server that returns invalid response
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		llmResponse := response{
			Choices: []choice{
				{
					Message: Message{
						Content: "Invalid Category", // Not in the allowed list
					},
				},
			},
		}
		b, _ := json.Marshal(llmResponse)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have an error about invalid LLM output
	if len(task.Errors) == 0 {
		t.Error("Expected error for invalid LLM output, got none")
	}

	// Record should be removed due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected record to be removed due to error, got %d records", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_UpdateRecordError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "Test content",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "radio\nTechnical\nAccount\nBilling\nOther",
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/") && r.Method == "POST" {
			// Mock record update failure
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("Update failed"))
		}
	}))
	defer ts.Close()

	// Mock LLM server
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		llmResponse := response{
			Choices: []choice{
				{
					Message: Message{
						Content: "Technical",
					},
				},
			},
		}
		b, _ := json.Marshal(llmResponse)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have an error from UpdateRecord
	if len(task.Errors) == 0 {
		t.Error("Expected error for UpdateRecord failure, got none")
	}

	// Record should be removed due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected record to be removed due to error, got %d records", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_RecordNotInSet(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "Test content",
					},
				},
				2: { // This record is not in the task.Records set
					S1: map[string]string{
						"id100": "Another test content",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "radio\nTechnical\nAccount\nBilling\nOther",
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/") && r.Method == "POST" {
			w.WriteHeader(http.StatusOK)
		}
	}))
	defer ts.Close()

	// Mock LLM server
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		llmResponse := response{
			Choices: []choice{
				{
					Message: Message{
						Content: "Technical",
					},
				},
			},
		}
		b, _ := json.Marshal(llmResponse)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {}, // Only record 1 is in the set
		},
	}

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have no errors and only process record 1
	if len(task.Errors) != 0 {
		t.Errorf("Expected no errors, got %d errors: %v", len(task.Errors), task.Errors)
	}

	// Record should still be in the set
	if len(task.Records) != 1 {
		t.Errorf("Expected 1 record in set, got %d", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_WithEmptyContext(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "Test content",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "radio\nTechnical\nAccount\nBilling\nOther",
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/") && r.Method == "POST" {
			w.WriteHeader(http.StatusOK)
		}
	}))
	defer ts.Close()

	// Mock LLM server
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify the prompt structure
		body := make([]byte, 1024)
		n, _ := r.Body.Read(body)
		var config Completions
		json.Unmarshal(body[:n], &config)

		// Check that the prompt is correctly formatted
		if len(config.Messages) != 2 {
			t.Errorf("Expected 2 messages, got %d", len(config.Messages))
		}

		llmResponse := response{
			Choices: []choice{
				{
					Message: Message{
						Content: "Technical",
					},
				},
			},
		}
		b, _ := json.Marshal(llmResponse)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100},
		WriteIndicatorID: 200,
		Context:          "", // Empty context
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have no errors
	if len(task.Errors) != 0 {
		t.Errorf("Expected no errors, got %d errors: %v", len(task.Errors), task.Errors)
	}

	// Record should still be in the set
	if len(task.Records) != 1 {
		t.Errorf("Expected 1 record in set, got %d", len(task.Records))
	}
}

func Test_UpdateDataLLMCategorization_WithEmptyDataFields(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.Contains(r.URL.Path, "api/form/query") {
			records := query.Response{
				1: {
					S1: map[string]string{
						"id100": "", // Empty field
						"id101": "", // Empty field
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/indicator/list") {
			indicators := []form.Indicator{
				{
					IndicatorID:   100,
					Name:          "Description",
					ShortLabel:    "Description",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   101,
					Name:          "Priority",
					ShortLabel:    "Priority",
					Format:        "text",
					FormatOptions: []string{},
				},
				{
					IndicatorID:   200,
					Name:          "Category",
					ShortLabel:    "Category",
					Format:        "radio\nTechnical\nAccount\nBilling\nOther",
					FormatOptions: []string{},
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		} else if strings.Contains(r.URL.Path, "api/form/") && r.Method == "POST" {
			w.WriteHeader(http.StatusOK)
		}
	}))
	defer ts.Close()

	// Mock LLM server
	llmTs := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Verify that empty context is handled
		body := make([]byte, 1024)
		n, _ := r.Body.Read(body)
		var config Completions
		json.Unmarshal(body[:n], &config)

		// The second message should have empty content since all fields are empty
		if config.Messages[1].Content != "" {
			t.Errorf("Expected empty content for second message, got: %s", config.Messages[1].Content)
		}

		llmResponse := response{
			Choices: []choice{
				{
					Message: Message{
						Content: "Other", // Default category when no context
					},
				},
			},
		}
		b, _ := json.Marshal(llmResponse)
		w.Write(b)
	}))
	defer llmTs.Close()

	agent.llmCategorizationURL = llmTs.URL

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateDataLLMCategorizationPayload{
		ReadIndicatorIDs: []int{100, 101},
		WriteIndicatorID: 200,
		Context:          "Categorize the request:",
	}

	agent.updateDataLLMCategorization(&task, payload)

	// Should have no errors
	if len(task.Errors) != 0 {
		t.Errorf("Expected no errors, got %d errors: %v", len(task.Errors), task.Errors)
	}

	// Record should still be in the set
	if len(task.Records) != 1 {
		t.Errorf("Expected 1 record in set, got %d", len(task.Records))
	}
}
