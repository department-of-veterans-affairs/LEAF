package main

import (
	"io"
	"net/http"
	"strings"
)

func httpGet(url string) (string, *http.Response) {
	url = strings.Replace(url, " ", "%20", -1)
	res, _ := client.Get(url)
	bodyBytes, _ := io.ReadAll(res.Body)
	return string(bodyBytes), res
}
