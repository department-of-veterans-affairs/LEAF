package main

import (
	"encoding/json"
	"io"
	"net/url"
	"strings"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func getFormQuery(url string) (FormQueryResponse, error) {
	url = strings.Replace(url, " ", "%20", -1)
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m FormQueryResponse
	err := json.Unmarshal(b, &m)

	return m, err
}

func TestPendingGroupDesignatedNames(t *testing.T) {
	xFilter := `recordID,categoryIDs,categoryNames,date,title,service,submitted,priority,stepID,blockingStepID,lastStatus,stepTitle,action_history.time,unfilledDependencyData`
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"stepID","operator":"=","match":"actionable","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","categoryName","status","unfilledDependencies"],"sort":{},"limit":10000,"limitOffset":0}&x-filterData=` + xFilter)

	rec581 := res[581].UnfilledDependencyData
	rec690 := res[690].UnfilledDependencyData
	rec550 := res[550].UnfilledDependencyData

	//testing two groups that exist to avoid chance false pass
	got := rec581["-3"].ApproverName
	want := "Aluminum Home"
	if !cmp.Equal(got, want) {
		t.Errorf("dependency group 581 name = %v, want = %v", got, want)
	}

	got = rec690["-3"].ApproverName
	want = "Office of Associate Director of Patient Care Services"
	if !cmp.Equal(got, want) {
		t.Errorf("dependency group 690 name = %v, want = %v", got, want)
	}

	//group that does not exist in the portal for warning display
	got = rec550["-3"].ApproverName
	want = "Warning: Group has not been imported into the User Access Group"
	if !cmp.Equal(got, want) {
		t.Errorf("dependency group 550 warning = %v, want = %v", got, want)
	}
}

func TestFormQuery_HomepageQuery(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"title","operator":"LIKE","match":"***","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)

	// get first key
	var key int
	for k := range res {
		key = k
		break
	}

	got := res[key].RecordID
	want := key

	if got != want {
		t.Errorf("RecordID = %v, want = %v", got, want)
	}
}

func TestFormQuery_NonadminQuery(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"stepID","operator":"!=","match":"resolved","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service"],"sort":{},"limit":1000,"limitOffset":0}&x-filterData=recordID,title&masquerade=nonAdmin`)

	if _, exists := res[958]; exists {
		t.Errorf("Record 958 should not be readable")
	}

	if _, exists := res[530]; !exists {
		t.Errorf("Record 530 should be readable")
	}
}

func TestFormQuery_NonadminQueryActionable(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"stepID","operator":"=","match":"actionable","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service"],"sort":{},"limit":1000,"limitOffset":0}&x-filterData=recordID,title&masquerade=nonAdmin`)

	if _, exists := res[503]; !exists {
		t.Errorf("Record 503 should be actionable because tester is backup of person designated")
	}

	if _, exists := res[504]; !exists {
		t.Errorf("Record 504 should be actionable because tester is backup of initiator")
	}

	if _, exists := res[505]; exists {
		t.Errorf("Record 505 should not be actionable because tester is not the requestor")
	}

	if _, exists := res[500]; !exists {
		t.Errorf("Record 500 should be actionable because tester is the designated reviewer")
	}

	if _, exists := res[531]; !exists {
		t.Errorf("Record 531 should be actionable because tester is a member of the designated group")
	}

	if _, exists := res[532]; exists {
		t.Errorf("Record 532 should not be actionable because tester is not a member of the designated group")
	}
}

func TestFormQuery_FulltextSearch_ApplePearOrange(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"data","indicatorID":"3","operator":"MATCH","match":"apple pear orange","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)

	if _, exists := res[499]; !exists {
		t.Errorf(`Record 499 should exist because a data field contains either apple, pear, or orange`)
	}

	if _, exists := res[498]; !exists {
		t.Errorf(`Record 498 should exist because a data field contains either apple, pear, or orange`)
	}
}

func TestFormQuery_FulltextSearch_TheOrangeOrPear_StopwordsNotRequired(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"data","indicatorID":"3","operator":"MATCH ALL","match":"The orange or pear","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)

	if _, exists := res[497]; !exists {
		t.Errorf(`Record 497 should exist because a data field contains "The apple, orange or pear"`)
	}

}

func TestFormQuery_FulltextSearch_ApplePear_RequireOrange(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"data","indicatorID":"3","operator":"MATCH","match":"apple pear %2Borange","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)

	if _, exists := res[499]; !exists {
		t.Errorf(`Record 499 should exist because a data field contains the word "orange"`)
	}

	if _, exists := res[498]; exists {
		t.Errorf(`Record 498 should not exist because data fields do not contain the word "orange"`)
	}
}

func TestFormQuery_FulltextSearch_ApplePearNoOrange(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"data","indicatorID":"3","operator":"MATCH","match":"apple pear %2Dorange","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)

	if _, exists := res[499]; exists {
		t.Errorf(`Record 499 should not exist because data fields contain the word "orange". want = no orange`)
	}

	if _, exists := res[498]; !exists {
		t.Errorf(`Record 498 should exist because data fields do not contain the word "orange"`)
	}
}

func TestFormQuery_RecordIdAndFulltext(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"recordID","operator":"=","match":"499","gate":"AND"},{"id":"data","indicatorID":"0","operator":"MATCH ALL","match":"apple","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)

	if _, exists := res[499]; !exists {
		t.Errorf(`Record 499 should exist because the data fields contain the word "apple". want = recordID IS 499 AND data contains apple`)
	}
}

func TestFormQuery_GroupClickedApprove(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query?q={"terms":[{"id":"stepAction","indicatorID":"4","operator":"=","match":"approve","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"date","direction":"DESC"},"limit":50}`)

	if _, exists := res[9]; !exists {
		t.Errorf(`Record 9 should exist because the "Group designated step" clicked "Approve". want = recordID 9 exists in the result set`)
	}
}

func TestFormQuery_FilterActionHistory(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query/?q={"terms":[{"id":"recordID","operator":"=","match":"9","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["action_history"],"sort":{},"limit":10000,"limitOffset":0}&x-filterData=recordID,title,action_history.time,action_history.description,action_history.actionTextPasttense,action_history.approverName`)

	if res[9].ActionHistory[0].RecordID != 0 {
		t.Errorf(`Record ID should not exist since it wasn't requested within action_history. want = action_history[0].recordID is null`)
	}

	if res[9].ActionHistory[0].ApproverName == "" {
		t.Errorf(`Approver name should not be empty since the record contains actions, and it was requested via filter want = action_history[0].approverName is not empty`)
	}
}

func TestFormQuery_DescendingIndex(t *testing.T) {
	// This test reproduces an issue where a descending recordID index in MySQL <= 8.4 results in unexpected query results
	// when 2 or more potential indexes can be used. Reliably reproducing this issue also requires a new record to be created.
	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("numform_5ea07", "1")
	postData.Set("title", "TestFormQuery_DescendingIndex")
	client.PostForm(RootURL+`api/form/new`, postData)

	res, _ := getFormQuery(RootURL + `api/form/query/?q={"terms":[{"id":"userID","operator":"=","match":"VTRSHHZOFIA","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["service","status","categoryName"],"sort":{"column":"recordID","direction":"DESC"},"limit":50}`)

	if _, exists := res[6]; !exists {
		t.Errorf(`Record ID should exist because VTRSHHZOFIA is the initiator. want = recordID is not null`)
	}
}

// TestFormQuery_FindTwoSteps looks for records on stepID 3 OR -3
func TestFormQuery_FindTwoSteps(t *testing.T) {
	res, _ := getFormQuery(RootURL + `api/form/query/?q={"terms":[{"id":"stepID","operator":"=","match":"3","gate":"AND"},{"id":"stepID","operator":"=","match":"-3","gate":"OR"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":[],"sort":{}}&x-filterData=recordID,stepID`)

	for _, record := range res {
		if record.StepID != 3 && record.StepID != -3 {
			t.Errorf(`RecordID #%v StepID = %v. want = stepID is 3 OR -3`, record.RecordID, record.StepID)
		}
	}
}


/* post a new employee to an orgchart format question and then confirm expected values on orgchart property */
func TestFormQuery_Employee_Format__Orgchart_Has_Expected_Values(t *testing.T) {
	mock_orgchart_employee := FormQuery_Orgchart_Employee{
		FirstName: "Ramon",
		LastName: "Watsica",
		MiddleName: "Yundt",
		Email: "Ramon.Watsica@fake-email.com",
		UserName: "vtrycxbethany",
	}

	postData := url.Values{}
	postData.Set("CSRFToken", CsrfToken)
	postData.Set("8", "201")

	res, err := client.PostForm(RootURL+`api/form/11`, postData)
	if err != nil {
		t.Error("Error sending post request")
	}

	bodyBytes, _ := io.ReadAll(res.Body)
	got := string(bodyBytes)
	want := `"1"`
	if !cmp.Equal(got, want) {
		t.Errorf("Error posting orgchart entry.  Admin did not have access got = %v, want = %v", got, want)
	}

	formRes, _ := getFormQuery(RootURL + `api/form/query/?q={"terms":[{"id":"categoryID","operator":"=","match":"form_5ea07","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":[],"sort":{},"getData":["8"],"limit":10000,"limitOffset":0}&x-filterData=recordID,title`)
	if _, exists := formRes[11]; !exists {
		t.Errorf("Record 11 should be readable")
	}

	recData := formRes[11].S1

	dataInterface := recData["id8_orgchart"]
	orgchart := dataInterface.(map[string]interface {})
	b, _ := json.Marshal(orgchart)

	var org_emp FormQuery_Orgchart_Employee
	err = json.Unmarshal(b, &org_emp)
	if err != nil {
		t.Error("Error on FormQuery_Orgchart_Employee unmarshal")
	}

	got = org_emp.FirstName
	want = mock_orgchart_employee.FirstName
	if !cmp.Equal(got, want) {
		t.Errorf("firstName got = %v, want = %v", got, want)
	}
	got = org_emp.LastName
	want = mock_orgchart_employee.LastName
	if !cmp.Equal(got, want) {
		t.Errorf("lastName got = %v, want = %v", got, want)
	}
	got = org_emp.MiddleName
	want = mock_orgchart_employee.MiddleName
	if !cmp.Equal(got, want) {
		t.Errorf("middleName got = %v, want = %v", got, want)
	}
	got = org_emp.Email
	want = mock_orgchart_employee.Email
	if !cmp.Equal(got, want) {
		t.Errorf("email got = %v, want = %v", got, want)
	}
	got = org_emp.UserName
	want = mock_orgchart_employee.UserName
	if !cmp.Equal(got, want) {
		t.Errorf("userName got = %v, want = %v", got, want)
	}
}
