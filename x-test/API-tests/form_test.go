package main

import (
	"io"
	"net/url"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestForm_Version(t *testing.T) {
	got, _ := httpGet(RootURL + "api/form/version")
	want := `"1"`

	if !cmp.Equal(got, want) {
		t.Errorf("form version = %v, want = %v", got, want)
	}
}

func TestForm_AdminCanEditData(t *testing.T) {
	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("3", "12345")

	res, _ := client.PostForm(RootURL+`api/form/505`, postData)
	bodyBytes, _ := io.ReadAll(res.Body)
	got := string(bodyBytes)
	want := `"1"`

	if !cmp.Equal(got, want) {
		t.Errorf("Admin got = %v, want = %v", got, want)
	}
}

func TestForm_NonadminCannotEditData(t *testing.T) {
	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("3", "12345")

	res, _ := client.PostForm(RootURL+`api/form/505?masquerade=nonAdmin`, postData)
	bodyBytes, _ := io.ReadAll(res.Body)
	got := string(bodyBytes)
	want := `"0"`

	if !cmp.Equal(got, want) {
		t.Errorf("Non-admin got = %v, want = %v", got, want)
	}
}

func TestForm_NeedToKnowDataReadAccess(t *testing.T) {
	got, res := httpGet(RootURL + "api/form/505/data?masquerade=nonAdmin")
	if !cmp.Equal(res.StatusCode, 200) {
		t.Errorf("./api/form/505/data?masquerade=nonAdmin Status Code = %v, want = %v", res.StatusCode, 200)
	}
	want := `[]`
	if !cmp.Equal(got, want) {
		t.Errorf("Non-admin, non actor should not have read access to need to know record. got = %v, want = %v", got, want)
	}
}

func TestForm_RequestFollowupAllowCaseInsensitiveUserID(t *testing.T) {
	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("3", "12345")

	res, _ := client.PostForm(RootURL+`api/form/7?masquerade=nonAdmin`, postData)
	bodyBytes, _ := io.ReadAll(res.Body)
	got := string(bodyBytes)
	want := `"1"`

	if !cmp.Equal(got, want) {
		t.Errorf("Non-admin got = %v, want = %v", got, want)
	}
}

func TestForm_WorkflowIndicatorAssigned(t *testing.T) {
	got, res := httpGet(RootURL + "api/form/508/workflow/indicator/assigned")

	if !cmp.Equal(res.StatusCode, 200) {
		t.Errorf("./api/form/508/workflow/indicator/assigned Status Code = %v, want = %v", res.StatusCode, 200)
	}

	want := `[]`
	if !cmp.Equal(got, want) {
		t.Errorf("./api/form/508/workflow/indicator/assigned = %v, want = %v", got, want)
	}
}
