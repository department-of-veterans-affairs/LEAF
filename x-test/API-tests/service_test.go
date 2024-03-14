package main

import (
	"encoding/json"
	"io"
	"log"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func getService(url string) ServiceResponse {
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m ServiceResponse
	err := json.Unmarshal(b, &m)

	if err != nil {
		log.Printf("JSON parsing error, couldn't parse: %v", string(b))
		log.Printf("JSON parsing error: %v", err.Error())
	}
	return m
}

func TestService_getMembers(t *testing.T) {
	res := getService(rootURL + `api/service/members`)

	count := len(res)
	retrieved := 28

	if !cmp.Equal(count, retrieved) {
		t.Errorf("Array size = %v, wanted = %v", count, retrieved)
	}

	got := res[9].Service
	want := "Cotton Computers"
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", res, want)
	}
}
