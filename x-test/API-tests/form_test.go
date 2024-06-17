package main

import (
	"encoding/json"
	"io"
	"net/url"
	"strconv"
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

func TestForm_IsMaskable(t *testing.T) {
	res, _ := httpGet(RootURL + "api/form/_form_ce46b")

	var m FormCategoryResponse
	err := json.Unmarshal([]byte(res), &m)
	if err != nil {
		t.Error(err)
	}

	if m[0].IsMaskable != nil {
		t.Errorf("./api/form/_form_ce46b isMaskable = %v, want = %v", m[0].IsMaskable, nil)
	}

	res, _ = httpGet(RootURL + "api/form/_form_ce46b?context=formEditor")

	err = json.Unmarshal([]byte(res), &m)
	if err != nil {
		t.Error(err)
	}

	if *m[0].IsMaskable != 0 {
		t.Errorf("./api/form/_form_ce46b?context=formEditor isMaskable = %v, want = %v", m[0].IsMaskable, "0")
	}
}

func TestForm_NonadminCannotCancelOwnSubmittedRecord(t *testing.T) {
	// Setup conditions
	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("numform_5ea07", "1")
	postData.Set("title", "TestForm_NonadminCannotCancelOwnSubmittedRecord")
	postData.Set("8", "1")
	postData.Set("9", "112")

	// TODO: streamline this
	res, _ := client.PostForm(RootURL+`api/form/new`, postData)
	bodyBytes, _ := io.ReadAll(res.Body)
	var response string
	json.Unmarshal(bodyBytes, &response)
	recordID, err := strconv.Atoi(string(response))

	if err != nil {
		t.Errorf("Could not create record for TestForm_NonadminCannotCancelOwnSubmittedRecord: " + err.Error())
	}

	postData = url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	client.PostForm(RootURL+`api/form/`+strconv.Itoa(recordID)+`/submit`, postData)

	// Non-admin shouldn't be able to cancel a submitted record
	postData = url.Values{}
	postData.Set("CSRFToken", CsrfToken)

	res, _ = client.PostForm(RootURL+`api/form/`+strconv.Itoa(recordID)+`/cancel?masquerade=nonAdmin`, postData)
	bodyBytes, _ = io.ReadAll(res.Body)
	json.Unmarshal(bodyBytes, &response)
	got := response

	if got == "1" {
		t.Errorf("./api/form/[recordID]/cancel got = %v, want = %v", got, "An error message")
	}
}

func TestForm_FilterChildkeys(t *testing.T) {
	res, _ := httpGet(RootURL + "api/form/9/data/tree?x-filterData=child.name")

	var m FormCategoryResponse
	err := json.Unmarshal([]byte(res), &m)
	if err != nil {
		t.Error(err)
	}

	if m[0].Child[4].Name == "" {
		t.Errorf("./api/form/9/data/tree?x-filterData=child.name child[4].name = %v, want = %v", m[0].Child[4].Name, "")
	}

	if m[0].Child[4].IndicatorID != 0 {
		t.Errorf("./api/form/9/data/tree?x-filterData=child.name child[4].indicatorID = %v, want = %v", m[0].Child[4].IndicatorID, "undefined")
	}
}
