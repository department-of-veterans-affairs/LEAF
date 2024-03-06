package main

import (
	"encoding/json"
	"io"
	"log"
	"testing"
	"strconv"

	"github.com/google/go-cmp/cmp"
)

func TestFormStack_Version(t *testing.T) {
	got, _ := httpGet(rootURL + "api/formStack/version")
	want := `"1"`

	if !cmp.Equal(got, want) {
		t.Errorf("formStack Controler version = %v, want = %v", got, want)
	}
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

func TestFormStack_FormProperties(t *testing.T) {
	res := getFormStack(rootURL + `api/formStack/categoryList/all`)

	var category FormStackCategory
	for _, v := range res {
		if v.CategoryID == "form_5ea07" {
			category = v
			break
		}
	}

	got := category.ParentID
	want := ""
	if !cmp.Equal(got, want) {
		t.Errorf("ParentID = %v, want = %v", got, want)
	}

	got = category.CategoryName
	want = "General Form"
	if !cmp.Equal(got, want) {
		t.Errorf("Category Name = %v, want = %v", got, want)
	}

	got = category.CategoryDescription
	want = ""
	if !cmp.Equal(got, want) {
		t.Errorf("Category Description = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.WorkflowID)
	want = "1"
	if !cmp.Equal(got, want) {
		t.Errorf("WorkflowID = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.Sort)
	want = "0"
	if !cmp.Equal(got, want) {
		t.Errorf("Sort = %v, want = %v", got, want)
	}

	got = strconv.Itoa(category.NeedToKnow)
	want = "1"
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
	want = "General Workflow"
	if !cmp.Equal(got, want) {
		t.Errorf("Workflow Description = %v, want = %v", got, want)
	}

}