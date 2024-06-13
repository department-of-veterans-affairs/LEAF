package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"strings"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func getEmployee(url string) (EmployeeResponse, error) {
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m EmployeeResponse
	err := json.Unmarshal(b, &m)
	if err != nil {
		return nil, err
	}
	return m, err
}

func updateEmployees(url string) error {
	_, err := client.Get(url)
	if err != nil {
		return err
	}
	return nil
}

func postEmployee(postUrl string, data Employee) (string, error) {

	postData := url.Values{}
	postData.Set("firstName", data.FirstName)
	postData.Set("lastName", data.LastName)
	postData.Set("userName", data.UserName)
	postData.Set("CSRFToken", CsrfToken)

	// Send POST request
	res, err := client.PostForm(postUrl, postData)
	if err != nil {
		return "", err
	}

	bodyBytes, _ := io.ReadAll(res.Body)

	var c string
	err = json.Unmarshal(bodyBytes, &c)
	if err != nil {
		log.Printf("JSON parsing error, couldn't parse: %v", string(bodyBytes))
	}

	return c, nil
}

func disableEmployee(postUrl string) error {

	data := url.Values{}
	data.Set("CSRFToken", CsrfToken)

	req, err := http.NewRequest("DELETE", postUrl, strings.NewReader(data.Encode()))

	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := client.Do(req)

	if err != nil {
		return err
	}

	bodyBytes, _ := io.ReadAll(resp.Body)

	defer resp.Body.Close()

	var c string
	err = json.Unmarshal(bodyBytes, &c)
	if err != nil {
		log.Printf("JSON parsing error, couldn't parse: %v", string(bodyBytes))
	}

	return nil

}

func TestEmployee_CheckNationalEmployee(t *testing.T) {

	// make sure the users are in place before we start.
	m := Employee{
		FirstName: "test",
		LastName:  "user",
		UserName:  "testuser",
	}

	employeeId, err := postEmployee(NationalOrgchartURL+`api/employee/new`, m)

	if err != nil {
		t.Error(err)
	}

	if employeeId == "" {
		t.Error("no user id returned")
	}

	employeeId, err = postEmployee(RootOrgchartURL+`api/employee/new`, m)

	if err != nil {
		t.Error(err)
	}

	if employeeId == "" {
		t.Error("no user id returned")
	}

	var localEmployeeKey string
	var natEmployeeKey string

	natEmpoyeeRes, err := getEmployee(NationalOrgchartURL + `api/employee/search?q=username:testuser`)

	if err != nil {
		t.Error(err)
	}

	for key := range natEmpoyeeRes {
		natEmployeeKey = key
		break
	}

	localEmployeeRes, _ := getEmployee(RootOrgchartURL + `api/employee/search?q=username:testuser`)
	for key := range localEmployeeRes {
		localEmployeeKey = key
		break
	}

	got := localEmployeeRes[localEmployeeKey].UserName
	want := m.UserName

	if !cmp.Equal(got, want) {
		t.Errorf("got = %v, want = %v", got, want)
	}

	got = natEmpoyeeRes[natEmployeeKey].UserName
	if !cmp.Equal(got, want) {
		t.Errorf("got = %v, want = %v", got, want)
	}

	// delete remote employee
	err = disableEmployee(fmt.Sprintf("%sapi/employee/%s", NationalOrgchartURL, natEmployeeKey))
	if err != nil {
		t.Error(err)
	}

	// make sure the national is disabled
	res, _ := getEmployee(NationalOrgchartURL + `api/employee/search?q=username:testuser`)

	gotId := fmt.Sprintf("%d", res[natEmployeeKey].EmployeeId)
	wantId := natEmployeeKey
	if cmp.Equal(gotId, wantId) {
		t.Errorf("User was not disabled on national - got = %s, want = %s", gotId, wantId)
	}

	// make sure the local is not disabled
	res, _ = getEmployee(RootOrgchartURL + `api/employee/search?q=username:testuser`)

	gotId = fmt.Sprintf("%d", res[localEmployeeKey].EmployeeId)
	wantId = localEmployeeKey
	if !cmp.Equal(gotId, wantId) {
		t.Errorf("User was disabled on local - got = %s, want = %s", gotId, wantId)
	}

	// run script again, make sure it deletes locally
	err = updateEmployees(RootOrgchartURL + `scripts/refreshOrgchartEmployees.php`)
	if err != nil {
		t.Error(err)
	}

	// make sure the national entry was deleted
	res, _ = getEmployee(NationalOrgchartURL + `api/employee/search?q=username:testuser`)

	if len(res) > 0 {
		t.Error("User Exists on national")
	}

	// make sure the local has been deleted.
	res, _ = getEmployee(RootOrgchartURL + `api/employee/search?q=username:testuser`)

	if len(res) > 0 {
		t.Error("User Exists on local")
	}

}
