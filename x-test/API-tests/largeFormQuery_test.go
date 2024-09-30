package main

import (
	"encoding/json"
	"io"
	"strings"
	"testing"
)

func TestLargeFormQuery_SmallQuery(t *testing.T) {
	url := RootURL + `api/form/query/?q={"terms":[{"id":"stepID","operator":"!=","match":"resolved","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["status","initiatorName"],"sort":{},"limit":10000,"getData":["9","8","10","4","5","7","3","6","2"]}&x-filterData=recordID,title,stepTitle,lastStatus,lastName,firstName`

	url = strings.Replace(url, " ", "%20", -1)
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var formQueryResponse FormQueryResponse
	_ = json.Unmarshal(b, &formQueryResponse)

	if _, exists := formQueryResponse[958]; !exists {
		t.Errorf("Record 958 should be readable")
	}

	if v, ok := res.Header["Leaf_large_queries"]; ok && (len(v) != 1 || v[0] != "pass_onto_large_query_server") {
		t.Errorf("bad headers: %v", res.Header)
	}
}

func TestLargeFormQuery_LargeQuery(t *testing.T) {
	url := RootURL + `api/form/query/?q={"terms":[{"id":"stepID","operator":"!=","match":"resolved","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["status","initiatorName"],"sort":{},"getData":["9","8","10","4","5","7","3","6","2"]}&x-filterData=recordID,title,stepTitle,lastStatus,lastName,firstName`

	url = strings.Replace(url, " ", "%20", -1)
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var formQueryResponse FormQueryResponse
	_ = json.Unmarshal(b, &formQueryResponse)

	if _, exists := formQueryResponse[958]; !exists {
		t.Errorf("Record 958 should be readable")
	}

	if v, ok := res.Header["Leaf_large_queries"]; ok && (len(v) != 1 || v[0] != "process_ran_on_large_query_server") {
		t.Errorf("bad headers: %v", res.Header)
	}
}
