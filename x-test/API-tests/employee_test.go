package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
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

func updateEmployees(postUrl string) error {
	postData := url.Values{}
	postData.Set("CSRFToken", csrfToken)

	// Send POST request
	_, err := client.PostForm(postUrl, postData)
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
	postData.Set("CSRFToken", csrfToken)

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

	req, err := http.NewRequest("DELETE", postUrl, nil)

	resp, err := client.Do(req)

	if err != nil {
		return err
	}

	defer resp.Body.Close()

	return nil

}

func TestEmployee_CheckNationalEmployee(t *testing.T) {
	// make sure our test user is not on the nat already
	res, _ := getEmployee(natOrgURL + `api/employee/search?q=username:testuser`)

	if len(res) > 0 {
		t.Error("User Exists in national")
	}

	// make sure the test user is not on the orgchart already
	res, _ = getEmployee(orgURL + `api/employee/search?q=username:testuser`)

	if len(res) > 0 {
		t.Error("User Exists in local")
	}

	// create the test user on the nat oc
	m := Employee{
		FirstName: "test",
		LastName:  "user",
		UserName:  "testuser",
	}

	employeeId, err := postEmployee(natOrgURL+`api/employee/new`, m)

	if err != nil {
		t.Error(err)
	}

	if employeeId == "" {
		t.Error("no user id returned")
	}

	// run the script to refresh orgchart employees
	err = updateEmployees(orgURL + `api/employee/refresh/batch`)
	if err != nil {
		t.Error(err)
	}

	// does our local have it
	localEmployeeRes, _ := getEmployee(orgURL + `api/employee/search?q=username:testuser`)

	var localEmployeeKey int
	for key := range localEmployeeRes {
		localEmployeeKey = key
		break
	}

	got := localEmployeeRes[localEmployeeKey].UserName
	want := m.UserName

	if !cmp.Equal(got, want) {
		t.Errorf("got = %v, want = %v", got, want)
	}

	// does our national still exist.
	natEmpoyeeRes, _ := getEmployee(natOrgURL + `api/employee/search?q=username:testuser`)

	var natEmployeeKey int
	for key := range natEmpoyeeRes {
		natEmployeeKey = key
		break
	}
	got = natEmpoyeeRes[natEmployeeKey].UserName
	if !cmp.Equal(got, want) {
		t.Errorf("got = %v, want = %v", got, want)
	}

	// local and nat employee ids we are looking at.
	natEmpoyeeResEmployeeId := natEmpoyeeRes[natEmployeeKey].EmployeeId
	localEmpoyeeResEmployeeId := localEmployeeRes[localEmployeeKey].EmployeeId

	// delete remote employee
	err = disableEmployee(fmt.Sprintf("%sapi/employee/%d", natOrgURL, natEmpoyeeResEmployeeId))
	if err != nil {
		t.Error(err)
	}

	// make sure the national entry was deleted
	res, _ = getEmployee(natOrgURL + `api/employee/search?q=username:testuser`)

	if len(res) > 0 {
		t.Error("User Exists on national")
	}

	// make sure the local has not been deleted.
	res, _ = getEmployee(orgURL + `api/employee/search?q=username:testuser`)

	gotId := res[0].EmployeeId
	wantId := localEmpoyeeResEmployeeId
	if !cmp.Equal(gotId, wantId) {
		t.Errorf("got = %v, want = %v", gotId, wantId)
	}

	// run script again, make sure it deletes locally
	err = updateEmployees(orgURL + `scripts/refreshOrgchartEmployees.php`)
	if err != nil {
		t.Error(err)
	}

	// make sure the national entry was deleted
	res, _ = getEmployee(natOrgURL + `api/employee/search?q=username:testuser`)

	if len(res) > 0 {
		t.Error("User Exists on national")
	}

	// make sure the local has been deleted.
	res, _ = getEmployee(orgURL + `api/employee/search?q=username:testuser`)

	if len(res) > 0 {
		t.Error("User Exists on local")
	}
}
