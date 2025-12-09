package agent

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form"
	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
	"github.com/department-of-veterans-affairs/LEAF/pkg/workflow"
)

// TestRouteLLM_WithRecords tests that routeLLM calls TakeAction once per record
// when records are returned by FormQuery and exist in task.Records.
func TestRouteLLM_WithRecords(t *testing.T) {
	callCount := 0
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/api/form/query":
			// Mock FormQuery response
			records := query.Response{
				1: {
					S1: map[string]string{
						"id1": "value1",
						"id2": "value2",
					},
				},
				2: {
					S1: map[string]string{
						"id1": "value3",
						"id2": "value4",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		case "/api/workflow/step/1/actions":
			// Mock GetActions response
			actions := []workflow.Action{
				{
					ActionType: "approve",
					ActionText: "Approve",
				},
				{
					ActionType: "reject",
					ActionText: "Reject",
				},
			}
			b, _ := json.Marshal(actions)
			w.Write(b)
		case "/api/form/indicator/list":
			// Mock GetIndicatorMap response
			indicators := []form.Indicator{
				{
					IndicatorID: 1,
					Name:        "Indicator 1",
				},
				{
					IndicatorID: 2,
					Name:        "Indicator 2",
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		case "/api/formWorkflow/1/apply":
			// Mock TakeAction response for record 1
			callCount++
			w.WriteHeader(http.StatusOK)
		case "/api/formWorkflow/2/apply":
			// Mock TakeAction response for record 2
			callCount++
			w.WriteHeader(http.StatusOK)
		case "/llm":
			// Mock LLM response returning "Approve"
			w.Write([]byte(`{"choices":[{"message":{"content":"Approve"}}]}`))
			return
		default:
			t.Errorf("Unexpected path: %s", r.URL.Path)
		}
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
		TaskID: 1,
		StepID: "1",
	}

	payload := RouteLLMPayload{
		ReadIndicatorIDs: []int{1, 2},
		Context:          "",
	}

	// Configure LLM endpoint to point to mock server
	os.Setenv("LLM_CATEGORIZATION_URL", ts.URL+"/llm")

	agent.routeLLM(&task, payload)

	expectedCalls := len(task.Records)
	if callCount != expectedCalls {
		t.Errorf("expected %d calls to TakeAction, got %d", expectedCalls, callCount)
	}
}

// TestRouteLLM_NoRecords tests that routeLLM returns early when no records match the query.
func TestRouteLLM_NoRecords(t *testing.T) {
	callCount := 0
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/api/form/query":
			// Mock empty FormQuery response
			records := query.Response{}
			b, _ := json.Marshal(records)
			w.Write(b)
		case "/api/workflow/step/1/actions":
			callCount++
			// Mock GetActions response
			actions := []workflow.Action{
				{
					ActionType: "approve",
					ActionText: "Approve",
				},
			}
			b, _ := json.Marshal(actions)
			w.Write(b)
		default:
			t.Errorf("Unexpected path: %s", r.URL.Path)
		}
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			1: {},
		},
		TaskID: 1,
		StepID: "1",
	}

	payload := RouteLLMPayload{
		ReadIndicatorIDs: []int{1},
		Context:          "",
	}

	agent.routeLLM(&task, payload)

	if callCount != 0 {
		t.Errorf("expected 0 calls to TakeAction, got %d", callCount)
	}
}

// TestRouteLLM_InvalidAction tests that routeLLM handles invalid LLM responses correctly.
func TestRouteLLM_InvalidAction(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/api/form/query":
			// Mock FormQuery response
			records := query.Response{
				1: {
					S1: map[string]string{
						"id1": "value1",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		case "/api/workflow/step/1/actions":
			// Mock GetActions response
			actions := []workflow.Action{
				{
					ActionType: "approve",
					ActionText: "Approve",
				},
			}
			b, _ := json.Marshal(actions)
			w.Write(b)
		case "/api/form/indicator/list":
			// Mock GetIndicatorMap response
			indicators := []form.Indicator{
				{
					IndicatorID: 1,
					Name:        "Indicator 1",
				},
			}
			b, _ := json.Marshal(indicators)
			w.Write(b)
		case "/llm":
			// Mock LLM response returning an invalid action
			w.Write([]byte(`{"choices":[{"message":{"content":"InvalidAction"}}]}`))
			return
		default:
			t.Errorf("Unexpected path: %s", r.URL.Path)
		}
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			1: {},
		},
		TaskID: 1,
		StepID: "1",
	}

	payload := RouteLLMPayload{
		ReadIndicatorIDs: []int{1},
		Context:          "",
	}

	// Configure LLM endpoint to point to mock server
	os.Setenv("LLM_CATEGORIZATION_URL", ts.URL+"/llm")

	agent.routeLLM(&task, payload)

	// Verify that the invalid LLM response caused the record to be removed from task.Records
	if _, exists := task.Records[1]; exists {
		t.Errorf("expected record 1 to be removed from task.Records after invalid LLM action")
	}
}

// TestRouteLLM_DisallowedActions tests that routeLLM returns an error when LLM tries to use disallowed actions.
func TestRouteLLM_DisallowedActions(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/api/form/query":
			// Mock FormQuery response
			records := query.Response{
				1: {
					S1: map[string]string{
						"id1": "value1",
					},
				},
			}
			b, _ := json.Marshal(records)
			w.Write(b)
		case "/api/workflow/step/1/actions":
			// Mock GetActions response with disallowed actions
			actions := []workflow.Action{
				{
					ActionType: "approve",
					ActionText: "Approve",
				},
				{
					ActionType: "deny",
					ActionText: "Deny",
				},
			}
			b, _ := json.Marshal(actions)
			w.Write(b)
		case "/llm":
			// Mock LLM response returning "Approve"
			w.Write([]byte(`{"choices":[{"message":{"content":"Approve"}}]}`))
			return
		default:
			t.Errorf("Unexpected path: %s", r.URL.Path)
		}
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		Records: map[int]struct{}{
			1: {},
		},
		TaskID: 1,
		StepID: "1",
	}

	payload := RouteLLMPayload{
		ReadIndicatorIDs: []int{1},
		Context:          "",
	}

	// Configure LLM endpoint to point to mock server
	os.Setenv("LLM_CATEGORIZATION_URL", ts.URL+"/llm")

	agent.routeLLM(&task, payload)

	// Verify that the disallowed action caused the record to be removed from task.Records
	if _, exists := task.Records[1]; exists {
		t.Errorf("expected record 1 to be removed from task.Records after invalid LLM action")
	}
}
