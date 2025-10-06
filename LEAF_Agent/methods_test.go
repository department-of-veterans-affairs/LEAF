package main

import (
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"
)

func TestTakeAction(t *testing.T) {
	tests := []struct {
		name           string
		siteURL        string
		recID          int
		stepID         string
		actionType     string
		comment        string
		mockStatus     int
		mockResponse   string
		expectedError  bool
		expectedErrMsg string
	}{
		{
			name:          "Successful action with 200 status",
			siteURL:       "https://example.com/",
			recID:         123,
			stepID:        "step1",
			actionType:    "approve",
			comment:       "Approved",
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
		{
			name:          "Successful action with 202 status",
			siteURL:       "https://example.com/",
			recID:         456,
			stepID:        "step2",
			actionType:    "reject",
			comment:       "Rejected",
			mockStatus:    202,
			mockResponse:  "",
			expectedError: false,
		},
		{
			name:           "Failed action with 400 status",
			siteURL:        "https://example.com/",
			recID:          789,
			stepID:         "step3",
			actionType:     "invalid",
			comment:        "Test",
			mockStatus:     400,
			mockResponse:   "Bad request",
			expectedError:  true,
			expectedErrMsg: "Failed to take action: Bad request",
		},
		{
			name:           "Failed action with 500 status",
			siteURL:        "https://example.com/",
			recID:          999,
			stepID:         "step4",
			actionType:     "approve",
			comment:        "Test",
			mockStatus:     500,
			mockResponse:   "Internal server error",
			expectedError:  true,
			expectedErrMsg: "Failed to take action: Internal server error",
		},
		{
			name:          "Site URL without trailing slash",
			siteURL:       "https://example.com",
			recID:         111,
			stepID:        "step5",
			actionType:    "approve",
			comment:       "Test",
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create a test server to mock the HTTP response
			ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				// Verify the request method and path
				if r.Method != "POST" {
					t.Errorf("Expected POST request, got %s", r.Method)
				}

				expectedPath := "/api/formWorkflow/" + strconv.Itoa(tt.recID) + "/apply"
				if r.URL.Path != expectedPath {
					t.Errorf("Expected path %s, got %s", expectedPath, r.URL.Path)
				}

				// Verify the request body contains the expected form data
				if err := r.ParseForm(); err != nil {
					t.Errorf("Error parsing form: %v", err)
				}

				if r.FormValue("dependencyID") != "-4" {
					t.Errorf("Expected dependencyID -4, got %s", r.FormValue("dependencyID"))
				}

				if r.FormValue("stepID") != tt.stepID {
					t.Errorf("Expected stepID %s, got %s", tt.stepID, r.FormValue("stepID"))
				}

				if r.FormValue("actionType") != tt.actionType {
					t.Errorf("Expected actionType %s, got %s", tt.actionType, r.FormValue("actionType"))
				}

				if r.FormValue("comment") != tt.comment {
					t.Errorf("Expected comment %s, got %s", tt.comment, r.FormValue("comment"))
				}

				// Verify Authorization header
				if r.Header.Get("Authorization") != AGENT_TOKEN {
					t.Errorf("Expected Authorization header %s, got %s", AGENT_TOKEN, r.Header.Get("Authorization"))
				}

				w.WriteHeader(tt.mockStatus)
				w.Write([]byte(tt.mockResponse))
			}))
			defer ts.Close()

			// Replace the siteURL with the test server URL
			testSiteURL := strings.Replace(tt.siteURL, "https://example.com", ts.URL, 1)

			err := TakeAction(testSiteURL, tt.recID, tt.stepID, tt.actionType, tt.comment)

			if tt.expectedError {
				if err == nil {
					t.Errorf("Expected error, got nil")
				} else if err.Error() != tt.expectedErrMsg {
					t.Errorf("Expected error message '%s', got '%s'", tt.expectedErrMsg, err.Error())
				}
			} else {
				if err != nil {
					t.Errorf("Expected no error, got %v", err)
				}
			}
		})
	}
}

func TestUpdateRecord(t *testing.T) {
	tests := []struct {
		name           string
		siteURL        string
		recID          int
		data           map[int]string
		mockStatus     int
		mockResponse   string
		expectedError  bool
		expectedErrMsg string
	}{
		{
			name:          "Successful update with 200 status",
			siteURL:       "https://example.com/",
			recID:         123,
			data:          map[int]string{1: "value1", 2: "value2"},
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
		{
			name:           "Failed update with 400 status",
			siteURL:        "https://example.com/",
			recID:          456,
			data:           map[int]string{1: "invalid"},
			mockStatus:     400,
			mockResponse:   "Invalid data",
			expectedError:  true,
			expectedErrMsg: "Failed to update record: Invalid data",
		},
		{
			name:           "Failed update with 500 status",
			siteURL:        "https://example.com/",
			recID:          789,
			data:           map[int]string{1: "test"},
			mockStatus:     500,
			mockResponse:   "Server error",
			expectedError:  true,
			expectedErrMsg: "Failed to update record: Server error",
		},
		{
			name:          "Site URL without trailing slash",
			siteURL:       "https://example.com",
			recID:         111,
			data:          map[int]string{1: "test"},
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
		{
			name:          "Empty data map",
			siteURL:       "https://example.com/",
			recID:         222,
			data:          map[int]string{},
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create a test server to mock the HTTP response
			ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				// Verify the request method and path
				if r.Method != "POST" {
					t.Errorf("Expected POST request, got %s", r.Method)
				}

				expectedPath := "/api/form/" + strconv.Itoa(tt.recID)
				if r.URL.Path != expectedPath {
					t.Errorf("Expected path %s, got %s", expectedPath, r.URL.Path)
				}

				// Verify the request body contains the expected form data
				if err := r.ParseForm(); err != nil {
					t.Errorf("Error parsing form: %v", err)
				}

				// Verify all data fields are present in the form
				for k, v := range tt.data {
					key := strconv.Itoa(k)
					if r.FormValue(key) != v {
						t.Errorf("Expected %s=%s, got %s=%s", key, v, key, r.FormValue(key))
					}
				}

				// Verify Authorization header
				if r.Header.Get("Authorization") != AGENT_TOKEN {
					t.Errorf("Expected Authorization header %s, got %s", AGENT_TOKEN, r.Header.Get("Authorization"))
				}

				w.WriteHeader(tt.mockStatus)
				w.Write([]byte(tt.mockResponse))
			}))
			defer ts.Close()

			// Replace the siteURL with the test server URL
			testSiteURL := strings.Replace(tt.siteURL, "https://example.com", ts.URL, 1)

			err := UpdateRecord(testSiteURL, tt.recID, tt.data)

			if tt.expectedError {
				if err == nil {
					t.Errorf("Expected error, got nil")
				} else if err.Error() != tt.expectedErrMsg {
					t.Errorf("Expected error message '%s', got '%s'", tt.expectedErrMsg, err.Error())
				}
			} else {
				if err != nil {
					t.Errorf("Expected no error, got %v", err)
				}
			}
		})
	}
}

func TestUpdateTitle(t *testing.T) {
	tests := []struct {
		name           string
		siteURL        string
		recID          int
		title          string
		mockStatus     int
		mockResponse   string
		expectedError  bool
		expectedErrMsg string
	}{
		{
			name:          "Successful title update with 200 status",
			siteURL:       "https://example.com/",
			recID:         123,
			title:         "New Title",
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
		{
			name:           "Failed title update with 400 status",
			siteURL:        "https://example.com/",
			recID:          456,
			title:          "Invalid Title",
			mockStatus:     400,
			mockResponse:   "Invalid title",
			expectedError:  true,
			expectedErrMsg: "Failed to update record title: Invalid title",
		},
		{
			name:           "Failed title update with 500 status",
			siteURL:        "https://example.com/",
			recID:          789,
			title:          "Test Title",
			mockStatus:     500,
			mockResponse:   "Server error",
			expectedError:  true,
			expectedErrMsg: "Failed to update record title: Server error",
		},
		{
			name:          "Site URL without trailing slash",
			siteURL:       "https://example.com",
			recID:         111,
			title:         "Test Title",
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
		{
			name:          "Empty title",
			siteURL:       "https://example.com/",
			recID:         222,
			title:         "",
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
		{
			name:          "Title with special characters",
			siteURL:       "https://example.com/",
			recID:         333,
			title:         "Title with spaces & symbols!",
			mockStatus:    200,
			mockResponse:  "",
			expectedError: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create a test server to mock the HTTP response
			ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				// Verify the request method and path
				if r.Method != "POST" {
					t.Errorf("Expected POST request, got %s", r.Method)
				}

				expectedPath := "/api/form/" + strconv.Itoa(tt.recID) + "/title"
				if r.URL.Path != expectedPath {
					t.Errorf("Expected path %s, got %s", expectedPath, r.URL.Path)
				}

				// Verify the request body contains the expected form data
				if err := r.ParseForm(); err != nil {
					t.Errorf("Error parsing form: %v", err)
				}

				if r.FormValue("title") != tt.title {
					t.Errorf("Expected title %s, got %s", tt.title, r.FormValue("title"))
				}

				// Verify Authorization header
				if r.Header.Get("Authorization") != AGENT_TOKEN {
					t.Errorf("Expected Authorization header %s, got %s", AGENT_TOKEN, r.Header.Get("Authorization"))
				}

				w.WriteHeader(tt.mockStatus)
				w.Write([]byte(tt.mockResponse))
			}))
			defer ts.Close()

			// Replace the siteURL with the test server URL
			testSiteURL := strings.Replace(tt.siteURL, "https://example.com", ts.URL, 1)

			err := UpdateTitle(testSiteURL, tt.recID, tt.title)

			if tt.expectedError {
				if err == nil {
					t.Errorf("Expected error, got nil")
				} else if err.Error() != tt.expectedErrMsg {
					t.Errorf("Expected error message '%s', got '%s'", tt.expectedErrMsg, err.Error())
				}
			} else {
				if err != nil {
					t.Errorf("Expected no error, got %v", err)
				}
			}
		})
	}
}

// Test URL handling
func TestURLHandling(t *testing.T) {
	tests := []struct {
		name     string
		inputURL string
		expected string
	}{
		{
			name:     "URL with trailing slash",
			inputURL: "https://example.com/",
			expected: "https://example.com/",
		},
		{
			name:     "URL without trailing slash",
			inputURL: "https://example.com",
			expected: "https://example.com/",
		},
		{
			name:     "URL with path and trailing slash",
			inputURL: "https://example.com/path/",
			expected: "https://example.com/path/",
		},
		{
			name:     "URL with path without trailing slash",
			inputURL: "https://example.com/path",
			expected: "https://example.com/path/",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Test TakeAction URL handling
			ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				// The URL handling is tested by ensuring the request reaches our test server
				// and the path is correctly constructed
				var expectedPath string
				if strings.Contains(tt.inputURL, "/path") {
					expectedPath = "/path/api/formWorkflow/123/apply"
				} else {
					expectedPath = "/api/formWorkflow/123/apply"
				}
				if r.URL.Path != expectedPath {
					t.Errorf("Expected path %s, got %s", expectedPath, r.URL.Path)
				}
				w.WriteHeader(200)
			}))
			defer ts.Close()

			testURL := strings.Replace(tt.inputURL, "https://example.com", ts.URL, 1)
			err := TakeAction(testURL, 123, "step1", "approve", "test")
			if err != nil {
				t.Errorf("Unexpected error: %v", err)
			}
		})
	}
}
