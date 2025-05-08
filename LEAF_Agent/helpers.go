package main

import (
	"net/http"
	"net/url"
	"strings"
)

func HttpPost(url string, values url.Values) (res *http.Response, err error) {
	req, err := http.NewRequest("POST", url, strings.NewReader(values.Encode()))
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", AGENT_TOKEN)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	return client.Do(req)
}

func HttpGet(url string) (res *http.Response, err error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Authorization", AGENT_TOKEN)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	return client.Do(req)
}
