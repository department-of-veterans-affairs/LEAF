package main

import (
	"encoding/json"
	"io"
	"log"
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
	res := getFormWorkflow(rootURL + `api/formWorkflow/484/currentStep`)

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
