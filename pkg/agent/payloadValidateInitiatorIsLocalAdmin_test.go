package agent

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/department-of-veterans-affairs/LEAF/pkg/form/query"
	"github.com/department-of-veterans-affairs/LEAF/pkg/portal/group"
)

// Test_validateInitiatorIsLocalAdmin_Success tests the successful validation where initiator is a local admin
func Test_validateInitiatorIsLocalAdmin_Success(t *testing.T) {
	// Mock server for GetAdmins
	adminsTS := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		admins := []group.Member{
			{
				Username: "admin_user",
				EmpUID:   1001,
			},
			{
				Username: "another_admin",
				EmpUID:   1002,
			},
		}

		b, _ := json.Marshal(admins)
		w.Write(b)
	}))
	defer adminsTS.Close()

	// Mock server for FormQuery
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		records := query.Response{
			1: {
				RecordID: 1,
				UserName: "admin_user",
				S1: query.Data{
					"id123": adminsTS.URL, // This will be used as siteURL for GetAdmins
				},
			},
			2: {
				RecordID: 2,
				UserName: "regular_user",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
		}

		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	payload := ValidateInitiatorIsLocalAdmin{
		ReadIndicatorID: 123,
	}

	agent.validateInitiatorIsLocalAdmin(&task, payload)

	if _, exists := task.Records[1]; !exists {
		t.Errorf("Record 1 should exist (admin_user is admin), got = %v, want %v", exists, false)
	}

	if _, exists := task.Records[2]; exists {
		t.Errorf("Record 2 should not exist (regular_user is not admin), got = %v, want %v", exists, false)
	}
}

// Test_validateInitiatorIsLocalAdmin_FormQueryError tests when FormQuery returns an error
func Test_validateInitiatorIsLocalAdmin_FormQueryError(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Database error"))
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	payload := ValidateInitiatorIsLocalAdmin{
		ReadIndicatorID: 123,
	}

	agent.validateInitiatorIsLocalAdmin(&task, payload)

	// All records should be cleared due to error
	if len(task.Records) != 0 {
		t.Errorf("Expected 0 records (cleared due to error), got %d", len(task.Records))
	}

	// Should have one error
	if len(task.Errors) != 1 {
		t.Errorf("Expected 1 error, got %d", len(task.Errors))
	}

	if len(task.Errors) > 0 && task.Errors[0].RecordID != 0 {
		t.Errorf("Expected error for recordID 0 (global error), got %d", task.Errors[0].RecordID)
	}
}

// Test_validateInitiatorIsLocalAdmin_GetAdminsError tests when GetAdmins returns an error
func Test_validateInitiatorIsLocalAdmin_GetAdminsError(t *testing.T) {
	// Mock server for GetAdmins that returns an error
	adminsTS := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Admin service error"))
	}))
	defer adminsTS.Close()

	// Mock server for FormQuery
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		records := query.Response{
			1: {
				RecordID: 1,
				UserName: "admin_user",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
		}

		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
		},
	}

	payload := ValidateInitiatorIsLocalAdmin{
		ReadIndicatorID: 123,
	}

	agent.validateInitiatorIsLocalAdmin(&task, payload)

	// Record should be removed due to GetAdmins error
	if _, exists := task.Records[1]; exists {
		t.Errorf("Record 1 should not exist (GetAdmins error), got = %v, want %v", exists, false)
	}

	// Should have one error for record 1
	if len(task.Errors) != 1 {
		t.Errorf("Expected 1 error, got %d", len(task.Errors))
	}

	if len(task.Errors) > 0 && task.Errors[0].RecordID != 1 {
		t.Errorf("Expected error for recordID 1, got %d", task.Errors[0].RecordID)
	}
}

// Test_validateInitiatorIsLocalAdmin_MultipleAdmins tests with multiple admins and multiple records
func Test_validateInitiatorIsLocalAdmin_MultipleAdmins(t *testing.T) {
	// Mock server for GetAdmins
	adminsTS := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		admins := []group.Member{
			{
				Username: "admin1",
				EmpUID:   1001,
			},
			{
				Username: "admin2",
				EmpUID:   1002,
			},
			{
				Username: "admin3",
				EmpUID:   1003,
			},
		}

		b, _ := json.Marshal(admins)
		w.Write(b)
	}))
	defer adminsTS.Close()

	// Mock server for FormQuery
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		records := query.Response{
			1: {
				RecordID: 1,
				UserName: "admin1",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
			2: {
				RecordID: 2,
				UserName: "admin2",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
			3: {
				RecordID: 3,
				UserName: "non_admin",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
			4: {
				RecordID: 4,
				UserName: "admin3",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
		}

		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
			3: {},
			4: {},
		},
	}

	payload := ValidateInitiatorIsLocalAdmin{
		ReadIndicatorID: 123,
	}

	agent.validateInitiatorIsLocalAdmin(&task, payload)

	// Verify that admin records (1, 2, 4) still exist
	if _, exists := task.Records[1]; !exists {
		t.Errorf("Record 1 should exist (admin1 is admin), got = %v, want %v", exists, false)
	}

	if _, exists := task.Records[2]; !exists {
		t.Errorf("Record 2 should exist (admin2 is admin), got = %v, want %v", exists, false)
	}

	if _, exists := task.Records[4]; !exists {
		t.Errorf("Record 4 should exist (admin3 is admin), got = %v, want %v", exists, false)
	}

	// Verify that non-admin record (3) was removed
	if _, exists := task.Records[3]; exists {
		t.Errorf("Record 3 should not exist (non_admin is not admin), got = %v, want %v", exists, false)
	}

	// Verify that an error was added for the non-admin record
	if len(task.Errors) != 1 {
		t.Errorf("Expected 1 error for non-admin record, got %d", len(task.Errors))
	}

	if len(task.Errors) > 0 && task.Errors[0].RecordID != 3 {
		t.Errorf("Expected error for recordID 3 (non_admin), got %d", task.Errors[0].RecordID)
	}

	if len(task.Errors) > 0 && task.Errors[0].Error != "initiator is not a local site admin" {
		t.Errorf("Expected specific error message, got: %s", task.Errors[0].Error)
	}
}

// Test_validateInitiatorIsLocalAdmin_EmptyAdminsList tests when admins list is empty
func Test_validateInitiatorIsLocalAdmin_EmptyAdminsList(t *testing.T) {
	// Mock server for GetAdmins with empty list
	adminsTS := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		admins := []group.Member{} // Empty admin list
		b, _ := json.Marshal(admins)
		w.Write(b)
	}))
	defer adminsTS.Close()

	// Mock server for FormQuery
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		records := query.Response{
			1: {
				RecordID: 1,
				UserName: "user1",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
			2: {
				RecordID: 2,
				UserName: "user2",
				S1: query.Data{
					"id123": adminsTS.URL,
				},
			},
		}

		b, _ := json.Marshal(records)
		w.Write(b)
	}))
	defer ts.Close()

	task := Task{
		SiteURL: ts.URL,
		StepID:  "1",
		Records: map[int]struct{}{
			1: {},
			2: {},
		},
	}

	payload := ValidateInitiatorIsLocalAdmin{
		ReadIndicatorID: 123,
	}

	agent.validateInitiatorIsLocalAdmin(&task, payload)

	// Verify that both records were removed since there are no admins
	if _, exists := task.Records[1]; exists {
		t.Errorf("Record 1 should not exist (no admins in list), got = %v, want %v", exists, false)
	}

	if _, exists := task.Records[2]; exists {
		t.Errorf("Record 2 should not exist (no admins in list), got = %v, want %v", exists, false)
	}

	// Verify that errors were added for both records
	if len(task.Errors) != 2 {
		t.Errorf("Expected 2 errors for both records, got %d", len(task.Errors))
	}

	// Check that errors are for the correct record IDs
	errorRecordIDs := make(map[int]bool)
	for _, err := range task.Errors {
		errorRecordIDs[err.RecordID] = true
	}

	if !errorRecordIDs[1] {
		t.Errorf("Expected error for recordID 1")
	}

	if !errorRecordIDs[2] {
		t.Errorf("Expected error for recordID 2")
	}
}
