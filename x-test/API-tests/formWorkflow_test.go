package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func getFormWorkflow(url string) FormWorkflowResponse {
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m FormWorkflowResponse
	err := json.Unmarshal(b, &m)
	if err != nil {
		log.Printf("JSON parsing error, couldn't parse: %v", string(b))
		log.Printf("JSON parsing error: %v", err.Error())
	}
	return m
}

func TestFormWorkflow_currentStepPersonDesignatedAndGroup(t *testing.T) {
	res := getFormWorkflow(RootURL + `api/formWorkflow/484/currentStep`)

	got := res[9].Description
	want := "Group A"
	if !cmp.Equal(got, want) {
		t.Errorf("Description = %v, want = %v", got, want)
	}

	got = res[-1].Description
	want = "Step 1 (Omar Marvin)"
	if !cmp.Equal(got, want) {
		t.Errorf("Description = %v, want = %v", got, want)
	}

	gotPtr := res[9].ApproverName
	// approverName should not exist for depID 9
	if gotPtr != nil {
		t.Errorf("ApproverName = %v, want = %v", *gotPtr, nil)
	}
}

func TestFormWorkflow_ApplyAction(t *testing.T) {
	// Test invalid ID
	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("dependencyID", "invalid id")
	postData.Set("actionType", "approve")
	res, _ := client.PostForm(RootURL+`api/formWorkflow/8/apply`, postData)
	if res.StatusCode != http.StatusBadRequest {
		t.Errorf("api/formWorkflow/8/apply (invalid ID) StatusCode = %v, want = %v", res.StatusCode, http.StatusBadRequest)
	}

	// Test invalid action
	postData.Set("dependencyID", "-3")
	postData.Set("actionType", "TestFormWorkflow_ApplyAction-invalidAction")
	res, _ = client.PostForm(RootURL+`api/formWorkflow/8/apply`, postData)
	if res.StatusCode != http.StatusBadRequest {
		t.Errorf("api/formWorkflow/8/apply (invalid action) StatusCode = %v, want = %v", res.StatusCode, http.StatusBadRequest)
	}

	// Test valid ID
	postData.Set("dependencyID", "-3")
	postData.Set("actionType", "approve")
	res, _ = client.PostForm(RootURL+`api/formWorkflow/8/apply`, postData)
	if res.StatusCode != http.StatusOK {
		t.Errorf("api/formWorkflow/8/apply (valid ID) StatusCode = %v, want = %v", res.StatusCode, http.StatusOK)
	}

	// Test "page is out of date"
	postData.Set("dependencyID", "-3")
	postData.Set("actionType", "approve")
	res, _ = client.PostForm(RootURL+`api/formWorkflow/8/apply`, postData)
	if res.StatusCode != http.StatusConflict {
		t.Errorf("api/formWorkflow/8/apply ('page is out of date') StatusCode = %v, want = %v", res.StatusCode, http.StatusConflict)
	}
}
