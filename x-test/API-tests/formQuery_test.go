package main

import (
	"encoding/json"
	"io"
	"strings"
	"testing"
)

func getFormQuery(url string) (FormQueryResponse, error) {
	url = strings.Replace(url, " ", "%20", -1)
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m FormQueryResponse
	err := json.Unmarshal(b, &m)

	return m, err
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
