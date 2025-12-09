package agent

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"
)

// -----------------------------------------------------------------------------
// The test spins up a single httptest server that pretends to be the
// LEAF back-end.  The server implements the four HTTP endpoints that the
// production code calls:
//
//   - /api/form/query          – returns a set of records
//   - /api/form/indicator/list – returns a map of indicator metadata
//   - /api/llm                 – returns a fake LLM completion
//   - /api/form/<recordID>     – receives the update payload
//
// The server records the payload sent to the UpdateRecord endpoint so the test
// can assert that the correct data was written.
// -----------------------------------------------------------------------------
func TestUpdateData4BLLM(t *testing.T) {
	// -----------------------------------------------------------------------------
	// Helper types that mimic the JSON structures returned by the real services.
	// The definitions are deliberately minimal – they only contain the fields that
	// the `updateData4BLLM` function reads.
	// -----------------------------------------------------------------------------
	type mockRecord struct {
		S1 map[string]string `json:"s1"` // the field that holds indicator values
	}

	// The response from the LLM endpoint – only the fields accessed in the code.
	type mockLLMChoice struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	}
	type mockLLMResponse struct {
		Choices []mockLLMChoice `json:"choices"`
	}

	// -------------------------------------------------------------------------
	// 1. Prepare mock data that the function will consume.
	// -------------------------------------------------------------------------
	const (
		writeIndicatorID = 99
		stepID           = "42"
	)

	// Indicator metadata – only the fields used by the code are required.
	indicatorMap := []struct {
		IndicatorID int    `json:"indicatorID"`
		Format      string `json:"format"`
		Name        string `json:"name"`
	}{
		{IndicatorID: 1, Format: "text", Name: "First"},
		{IndicatorID: 2, Format: "textarea", Name: "Second"},
		{IndicatorID: writeIndicatorID, Format: "text", Name: "Result"},
	}

	// Records returned by the query endpoint.
	records := map[int]mockRecord{
		1: {S1: map[string]string{
			"id1": "value-one",
			"id2": "value-two",
		}},
		2: {S1: map[string]string{
			"id1": "only-first",
		}},
	}

	// The LLM will always return the same string – the test checks that this
	// string is written to the write-indicator field.
	const llmAnswer = "generated-text"

	// -------------------------------------------------------------------------
	// 2. Spin up the mock HTTP server.
	// -------------------------------------------------------------------------
	var receivedUpdates []struct {
		RecordID int
		Payload  map[string]string
	}
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Handle different endpoints based on URL path
		if strings.HasPrefix(r.URL.Path, "/api/form/query") {
			// Query endpoint – returns the records defined above.
			b, _ := json.Marshal(records)
			_, _ = w.Write(b)
			return
		} else if strings.HasPrefix(r.URL.Path, "/api/form/indicator/list") {
			// Indicator map endpoint.
			b, _ := json.Marshal(indicatorMap)
			_, _ = w.Write(b)
			return
		} else if strings.HasPrefix(r.URL.Path, "/api/llm") || strings.HasPrefix(r.URL.Path, "/api/llm/categorization") {
			// LLM endpoint – returns a single choice with the canned answer.
			resp := mockLLMResponse{
				Choices: []mockLLMChoice{
					{
						Message: struct {
							Content string `json:"content"`
						}{Content: llmAnswer},
					},
				},
			}
			b, _ := json.Marshal(resp)
			_, _ = w.Write(b)
			return
		} else if strings.HasPrefix(r.URL.Path, "/api/form/") {
			// UpdateRecord endpoint – capture the payload for later verification.
			parts := strings.Split(strings.Trim(r.URL.Path, "/"), "/")
			if len(parts) < 3 {
				http.Error(w, "bad path", http.StatusBadRequest)
				return
			}
			id, _ := strconv.Atoi(parts[2])

			if err := r.ParseForm(); err != nil {
				http.Error(w, "cannot parse form", http.StatusBadRequest)
				return
			}
			payload := make(map[string]string)
			for k, v := range r.PostForm {
				if len(v) > 0 {
					payload[k] = v[0]
				}
			}
			receivedUpdates = append(receivedUpdates, struct {
				RecordID int
				Payload  map[string]string
			}{RecordID: id, Payload: payload})

			// The real endpoint returns 200 on success.
			w.WriteHeader(http.StatusOK)
			return
		} else {
			// Any other request is an error
			http.NotFound(w, r)
			return
		}
	}))
	defer ts.Close()

	// -------------------------------------------------------------------------
	// 3. Build a minimal Task value.
	// -------------------------------------------------------------------------
	// Set environment for LLM calls to point to our mock server
	agent.llmCategorizationURL = ts.URL + "/api/llm"

	task := &Task{
		SiteURL: ts.URL + "/", // the code adds a trailing slash if missing
		StepID:  stepID,
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	// -------------------------------------------------------------------------
	// 4. Execute the function under test.
	// -------------------------------------------------------------------------
	payload := UpdateData4BLLMPayload{
		Context:          "extra context",
		ReadIndicatorIDs: []int{1, 2},
		WriteIndicatorID: writeIndicatorID,
	}
	agent.updateData4BLLM(task, payload)

	// -------------------------------------------------------------------------
	// 5. Verify that the LLM answer was written to each record that
	//    satisfied the step-ID filter.
	// -------------------------------------------------------------------------
	if len(receivedUpdates) != 2 {
		t.Errorf("expected 2 UpdateRecord calls, got %d", len(receivedUpdates))
	}
	for _, upd := range receivedUpdates {
		if upd.Payload[strconv.Itoa(writeIndicatorID)] != llmAnswer {
			t.Errorf("record %d: expected payload %q, got %q", upd.RecordID,
				llmAnswer, upd.Payload[strconv.Itoa(writeIndicatorID)])
		}
	}
}

// -----------------------------------------------------------------------------
// Ensure HTML tags are stripped from LLM output
// The mock server returns an LLM response with HTML tags. The test checks that
// these tags are removed from the final payload sent to UpdateRecord.
// -----------------------------------------------------------------------------
func TestUpdateData4BLLM_HTMLStripping(t *testing.T) {
	// -----------------------------------------------------------------------------
	// Helper types that mimic the JSON structures returned by the real services.
	// The definitions are deliberately minimal – they only contain the fields that
	// the `updateData4BLLM` function reads.
	// -----------------------------------------------------------------------------
	type mockRecord struct {
		S1 map[string]string `json:"s1"` // the field that holds indicator values
	}

	// The response from the LLM endpoint – only the fields accessed in the code.
	type mockLLMChoice struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	}
	type mockLLMResponse struct {
		Choices []mockLLMChoice `json:"choices"`
	}

	// -------------------------------------------------------------------------
	// 1. Prepare mock data that the function will consume.
	// -------------------------------------------------------------------------
	const (
		writeIndicatorID = 99
		stepID           = "42"
	)

	// Indicator metadata – only the fields used by the code are required.
	indicatorMap := []struct {
		IndicatorID int    `json:"indicatorID"`
		Format      string `json:"format"`
		Name        string `json:"name"`
	}{
		{IndicatorID: 1, Format: "text", Name: "First"},
		{IndicatorID: writeIndicatorID, Format: "text", Name: "Result"},
	}

	// Records returned by the query endpoint.
	records := map[int]mockRecord{
		1: {S1: map[string]string{
			"id1": "value-one",
		}},
	}

	// The LLM will return a response with HTML tags that should be stripped
	const llmAnswerWithHTML = "<p>This is <b>bold</b> text with <a href='#'>link</a></p>"

	// -------------------------------------------------------------------------
	// 2. Spin up the mock HTTP server.
	// -------------------------------------------------------------------------
	var receivedUpdates []struct {
		RecordID int
		Payload  map[string]string
	}
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Handle different endpoints based on URL path
		if strings.HasPrefix(r.URL.Path, "/api/form/query") {
			// Query endpoint – returns the records defined above.
			b, _ := json.Marshal(records)
			_, _ = w.Write(b)
			return
		} else if strings.HasPrefix(r.URL.Path, "/api/form/indicator/list") {
			// Indicator map endpoint.
			b, _ := json.Marshal(indicatorMap)
			_, _ = w.Write(b)
			return
		} else if strings.HasPrefix(r.URL.Path, "/api/llm") || strings.HasPrefix(r.URL.Path, "/api/llm/categorization") {
			// LLM endpoint – returns a single choice with the HTML content.
			resp := mockLLMResponse{
				Choices: []mockLLMChoice{
					{
						Message: struct {
							Content string `json:"content"`
						}{Content: llmAnswerWithHTML},
					},
				},
			}
			b, _ := json.Marshal(resp)
			_, _ = w.Write(b)
			return
		} else if strings.HasPrefix(r.URL.Path, "/api/form/") {
			// UpdateRecord endpoint – capture the payload for later verification.
			parts := strings.Split(strings.Trim(r.URL.Path, "/"), "/")
			if len(parts) < 3 {
				http.Error(w, "bad path", http.StatusBadRequest)
				return
			}
			id, _ := strconv.Atoi(parts[2])

			if err := r.ParseForm(); err != nil {
				http.Error(w, "cannot parse form", http.StatusBadRequest)
				return
			}
			payload := make(map[string]string)
			for k, v := range r.PostForm {
				if len(v) > 0 {
					payload[k] = v[0]
				}
			}
			receivedUpdates = append(receivedUpdates, struct {
				RecordID int
				Payload  map[string]string
			}{RecordID: id, Payload: payload})

			// The real endpoint returns 200 on success.
			w.WriteHeader(http.StatusOK)
			return
		} else {
			// Any other request is an error
			http.NotFound(w, r)
			return
		}
	}))
	defer ts.Close()

	// -------------------------------------------------------------------------
	// 3. Build a minimal Task value.
	// -------------------------------------------------------------------------
	// Set environment for LLM calls to point to our mock server
	agent.llmCategorizationURL = ts.URL + "/api/llm"

	task := &Task{
		SiteURL: ts.URL + "/", // the code adds a trailing slash if missing
		StepID:  stepID,
		Records: map[int]struct{}{
			1: {},
		},
	}

	// -------------------------------------------------------------------------
	// 4. Execute the function under test.
	// -------------------------------------------------------------------------
	payload := UpdateData4BLLMPayload{
		Context:          "extra context",
		ReadIndicatorIDs: []int{1},
		WriteIndicatorID: writeIndicatorID,
	}
	agent.updateData4BLLM(task, payload)

	// -------------------------------------------------------------------------
	// 5. Verify that HTML tags were stripped from the LLM answer and only
	//    clean text was written to the record.
	// -------------------------------------------------------------------------
	if len(receivedUpdates) != 1 {
		t.Errorf("expected 1 UpdateRecord call, got %d", len(receivedUpdates))
	}

	// The expected clean content should not contain HTML tags
	expectedCleanContent := "This is bold text with link"
	actualContent := receivedUpdates[0].Payload[strconv.Itoa(writeIndicatorID)]
	if actualContent != expectedCleanContent {
		t.Errorf("expected payload %q, got %q", expectedCleanContent, actualContent)
	}
}

// -----------------------------------------------------------------------------
// Early-exit when the query returns no records.
// The mock server returns an empty JSON object for the query endpoint.
// The function should return without calling any other endpoint.
// -----------------------------------------------------------------------------
func TestUpdateData4BLLM_NoRecords(t *testing.T) {
	var updateCalled bool
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Only the query endpoint is exercised.
		if strings.HasPrefix(r.URL.Path, "/api/form/query") {
			_, _ = w.Write([]byte("{}"))
			return
		}
		// Any other request indicates UpdateRecord was called.
		updateCalled = true
		// Respond with OK to avoid client errors.
		w.WriteHeader(http.StatusOK)
	}))
	defer ts.Close()

	task := &Task{
		SiteURL: ts.URL + "/",
		StepID:  "any",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := UpdateData4BLLMPayload{
		Context:          "",
		ReadIndicatorIDs: []int{1},
		WriteIndicatorID: 99,
	}
	agent.updateData4BLLM(task, payload)

	if updateCalled {
		t.Errorf("UpdateRecord was called when no records were returned")
	}
}
