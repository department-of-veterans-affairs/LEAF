package main

import (
	"encoding/json"
	"io"
	"strings"
	"testing"
)

func TestSmallQuery(t *testing.T) {
	url := RootURL + `api/form/query/?q={"terms":[{"id":"stepID","operator":"!=","match":"resolved","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["status","initiatorName"],"sort":{},"limit":10000,"getData":["9","8","10","4","5","7","3","6","2"]}&x-filterData=recordID,title,stepTitle,lastStatus,lastName,firstName`

	url = strings.Replace(url, " ", "%20", -1)
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var formQueryResponse FormQueryResponse
	_ = json.Unmarshal(b, &formQueryResponse)

	if _, exists := formQueryResponse[958]; !exists {
		t.Errorf("Record 958 should be readable")
	}

	if v, ok := res.Header["X-Nolargequeries"]; !ok || len(v) != 1 || v[0] != "transfer large queries to another server" {
		t.Errorf("bad headers: %v", res.Header)
	}
}

func TestLargeQuery(t *testing.T) {
	url := RootURL + `api/form/query/?q={"terms":[{"id":"stepID","operator":"!=","match":"resolved","gate":"AND"},{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["status","initiatorName"],"sort":{},"getData":["9","8","10","4","5","7","3","6","2"]}&x-filterData=recordID,title,stepTitle,lastStatus,lastName,firstName`

	url = strings.Replace(url, " ", "%20", -1)
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var formQueryResponse FormQueryResponse
	_ = json.Unmarshal(b, &formQueryResponse)

	if _, exists := formQueryResponse[958]; !exists {
		t.Errorf("Record 958 should be readable")
	}

	if v, ok := res.Header["X-Apiserver"]; !ok || len(v) != 1 || v[0] != "am on api server" {
		t.Errorf("bad headers: %v", res.Header)
	}
}
