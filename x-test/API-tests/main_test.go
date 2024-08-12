package main

import (
	"crypto/tls"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"os"
	"strings"
	"testing"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

const RootURL = "https://host.docker.internal/Test_Request_Portal/"
const NationalOrgchartURL = "https://host.docker.internal/LEAF_NationalNexus/"
const RootOrgchartURL = "https://host.docker.internal/Test_Nexus/"

var dbHost = os.Getenv("MYSQL_HOST")
var dbUsername = os.Getenv("MYSQL_USER")
var dbPassword = os.Getenv("MYSQL_PASSWORD")
var testPortalDbName = "leaf_portal_API_testing"
var testNexusDbName = "leaf_users_API_testing"

var CsrfToken string

var tr = &http.Transport{
	TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
}

var cookieJar, _ = cookiejar.New(nil)
var client = &http.Client{
	Transport: tr,
	Timeout:   time.Second * 5,
	Jar:       cookieJar,
}

// TestMain performs initial setup and logs into the dev environment.
// In dev, the current username is set via REMOTE_USER docker environment
func TestMain(m *testing.M) {

	setupTestDB()

	updateTestDBSchema()

	req, _ := http.NewRequest("GET", RootURL, nil)
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 Edg/118.0.2088.46")
	res, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}

	bodyBytes, err := io.ReadAll(res.Body)
	if err != nil {
		log.Fatal(err)
	}
	body := string(bodyBytes)

	startIdx := strings.Index(body, "var CSRFToken = '") + 17
	endIdx := strings.Index(body[startIdx:], "';")
	CsrfToken = body[startIdx : startIdx+endIdx]

	code := m.Run()

	teardownTestDB()

	os.Exit(code)
}
