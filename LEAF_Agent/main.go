package main

import (
	"crypto/tls"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"os"
	"time"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
)

var client *http.Client
var AGENT_TOKEN = os.Getenv("AGENT_TOKEN")
var HTTP_HOST = os.Getenv("APP_HTTP_HOST")

func main() {
	var tr = &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}

	var cookieJar, _ = cookiejar.New(nil)
	client = &http.Client{
		Transport: tr,
		Timeout:   time.Second * 5,
		Jar:       cookieJar,
	}

	log.Println("Starting LEAF Agent...")

	for {
		res, _ := HttpGet(`https://` + HTTP_HOST + `/platform/agent/api/form/query/?q={"terms":[{"id":"deleted","operator":"=","match":0,"gate":"AND"}],"joins":["status"],"sort":{}}&x-filterData=recordID,title,stepTitle,lastStatus`)

		b, _ := io.ReadAll(res.Body)

		var f query.Response
		json.Unmarshal(b, &f)

		log.Println(string(b))

		time.Sleep(10 * time.Second)
	}
}
