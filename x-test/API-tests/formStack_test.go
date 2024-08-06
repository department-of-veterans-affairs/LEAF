package main

import (
	"encoding/json"
	"io"
	"log"
	"net/url"
	"strconv"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestFormStack_Version(t *testing.T) {
	got, _ := httpGet(RootURL + "api/formStack/version")
	want := `"1"`

	if !cmp.Equal(got, want) {
		t.Errorf("formStack Controler version = %v, want = %v", got, want)
	}
}

func postNewForm() string {
	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("name", "Test New Form")
	postData.Set("description", "Test New Form Description")
	postData.Set("parentID", "")

	res, _ := client.PostForm(RootURL+`api/formEditor/new`, postData)
	bodyBytes, _ := io.ReadAll(res.Body)

	var c string
	err := json.Unmarshal(bodyBytes, &c)
	if err != nil {
		log.Printf("JSON parsing error, couldn't parse: %v", string(bodyBytes))
	}
	return c
}

func getFormStack(url string) FormStackResponse {
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m FormStackResponse
	err := json.Unmarshal(b, &m)
	if err != nil {
		log.Printf("JSON parsing error, couldn't parse: %v", string(b))
		log.Printf("JSON parsing error: %v", err.Error())
	}
	return m
}

func TestFormStack_NewFormProperties(t *testing.T) {
	catID := postNewForm()

	gotLen := len(catID)
	wantLen := 10
	if !cmp.Equal(gotLen, wantLen) {
		t.Errorf("new form return value length, got = %v, want = %v", gotLen, wantLen)
	}

	res := getFormStack(RootURL + `api/formStack/categoryList/all`)

	categoryTable := map[string]*FormStackCategory{}
	for _, v := range res {
		tmp := v
		categoryTable[v.CategoryID] = &tmp
	}

	category := categoryTable[catID]
	if category == nil {
		t.Errorf("New Form not found in table")
		return
	}

	got := category.ParentID
	want := ""
	if !cmp.Equal(got, want) {
		t.Errorf("ParentID = %v, want = %v", got, want)
	}

	got = category.CategoryName
	want = "Test New Form"
	if !cmp.Equal(got, want) {
		t.Errorf("Category Name = %v, want = %v", got, want)
	}

	got = category.CategoryDescription
	want = "Test New Form Description"
	if !cmp.Equal(got, want) {
		t.Errorf("Category Description = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.WorkflowID)
	want = "0"
	if !cmp.Equal(got, want) {
		t.Errorf("WorkflowID = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.Sort)
	want = "0"
	if !cmp.Equal(got, want) {
		t.Errorf("Sort = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.NeedToKnow)
	want = "0"
	if !cmp.Equal(got, want) {
		t.Errorf("Need to Know = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.FormLibraryID)
	want = "0"
	if !cmp.Equal(got, want) {
		t.Errorf("FormLibraryID = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.Visible)
	want = "1"
	if !cmp.Equal(got, want) {
		t.Errorf("Visible = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.Disabled)
	want = "0"
	if !cmp.Equal(got, want) {
		t.Errorf("Disabled = %v, want = %v", got, want)
	}

	got = category.Type
	want = ""
	if !cmp.Equal(got, want) {
		t.Errorf("Type = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.DestructionAge)
	want = "0"
	if !cmp.Equal(got, want) {
		t.Errorf("DestructionAge = %v, want = %v", got, want)
	}

	got = category.Description
	want = ""
	if !cmp.Equal(got, want) {
		t.Errorf("Workflow Description = %v, want = %v", got, want)
	}

}
