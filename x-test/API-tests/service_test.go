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

func getQuad(url string) QuadResponse {
	res, _ := client.Get(url)
	b, _ := io.ReadAll(res.Body)

	var m QuadResponse
	err := json.Unmarshal(b, &m)

	if err != nil {
		log.Printf("JSON parsing error, couldn't parse: %v", string(b))
		log.Printf("JSON parsing error: %v", err.Error())
	}
	return m
}

func TestService_getMembers(t *testing.T) {
	quads := getQuad(RootURL + `api/service/quadrads`)
	members := getService(RootURL + `api/service/members`)

	count := len(members)
	retrieved := 28

	if !cmp.Equal(count, retrieved) {
		t.Errorf("Array size = %v, wanted = %v", count, retrieved)
	}

	got := quads[0].Name
	want := members[0].Service
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", got, want)
	}

	got = quads[1].Name
	want = members[4].Service
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", got, want)
	}

	got = quads[2].Name
	want = members[6].Service
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", got, want)
	}

	got = quads[3].Name
	want = members[10].Service
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", got, want)
	}

	got = quads[4].Name
	want = members[11].Service
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", got, want)
	}

	got = quads[5].Name
	want = members[17].Service
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", got, want)
	}

	got = quads[6].Name
	want = members[20].Service
	if !cmp.Equal(got, want) {
		t.Errorf("Service = %v, want = %v", got, want)
	}
}
