package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/Pallinder/go-randomdata"
	_ "github.com/go-sql-driver/mysql"
)

var db *sql.DB
var dbHost = "leaf-mysql"
var dbUsername = os.Getenv("MYSQL_USER")
var dbPassword = os.Getenv("MYSQL_PASSWORD")
var portalDbName = "leaf_portal"
var nexusDbName = "leaf_users"

var origPortalDbName, origNexusDbName string
var origNexusDbNameForNexus string
var mysqlDSN = dbUsername + ":" + dbPassword + "@(" + dbHost + ")/?multiStatements=true"

type User struct {
	UserID  string
	GroupID int64
}

type Indicator struct {
	IndicatorID int64
	Name        string
}

// recordID,indicatorID,series,data,timestamp,userID
type Reqdata struct {
	RecordID    int64
	IndicatorID int64
	Series      int
	Data        string
	Timestamp   int64
	UserID      string
}

func main() {
	// Setup test database
	var err error
	db, err = sql.Open("mysql", mysqlDSN)
	if err != nil {
		log.Fatal("Couldn't open database, check DSN: ", err.Error())
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		log.Fatal("Can't ping database: ", err.Error())
	}

	db.Exec("USE " + portalDbName)

	fmt.Println(randomdata.SillyName())

	formid := "form_00fda"
	workflowName := "Herorhinestone"

	// check if workflow exists, if it does, then we will use that
	workflowID, isWorkflow := workflowExists(workflowName)
	if isWorkflow == false {
		workflowID = addWorkflow(workflowName)
	}

	// check if form exists we will assume everything else is there for now
	isForm := formExists(formid)
	if isForm == false {
		addForm(formid, randomdata.SillyName(), workflowID)
	}

	addRecords(formid, 100)
}

func workflowExists(description string) (int64, bool) {
	var workflowID int64
	err := db.QueryRow("SELECT workflowID FROM workflows WHERE description = ?", description).Scan(&workflowID)
	if err != nil {
		if err == sql.ErrNoRows {
			// No result found
			return 0, false
		}
		// Log the error and consider the user does not exist (to avoid insertion errors)
		log.Fatal("Error looking for workflow: ", err.Error())
		return 0, false
	}
	return workflowID, true
}

func addWorkflow(description string) int64 {

	// add in our workflow we will be assigning stuff to
	result, err := db.Exec("INSERT INTO workflows (initialStepID,description) VALUES  (?,?)", 0, description)
	if err != nil {
		log.Fatal("Can't insert workflow: ", err.Error())
	}

	workflowID, err := result.LastInsertId()
	if err != nil {
		log.Fatal("Can't receive last insert id: ", err.Error())
	}

	// add in our supporting workflow step
	result, err = db.Exec("INSERT INTO workflow_steps (workflowID,stepTitle,stepBgColor,stepFontColor,stepBorder,jsSrc) VALUES  (?,?,?,?,?,?)", workflowID, "The next steps", "#ff0000", "black", "1px solid black", "")
	if err != nil {
		log.Fatal("Can't insert workflow step: ", err.Error())
	}

	stepID, err := result.LastInsertId()
	if err != nil {
		log.Fatal("Can't receive last insert id: ", err.Error())
	}

	result, err = db.Exec("INSERT INTO workflow_routes (workflowID,stepID,nextStepID,actionType,displayConditional) VALUES  (?,?,?,?,?)", workflowID, stepID, "0", "sendback", "")
	if err != nil {
		log.Fatal("Can't insert workflow roots: ", err.Error())
	}

	return workflowID
}

func formExists(formid string) bool {
	var returnFormID string
	err := db.QueryRow("SELECT categoryID FROM categories WHERE categoryID = ?", formid).Scan(&returnFormID)
	if err != nil {
		if err == sql.ErrNoRows {
			// No result found
			return false
		}
		// Log the error and consider the user does not exist (to avoid insertion errors)
		log.Fatal("Error looking for form: ", err.Error())
		return false
	}
	return true
}

func addForm(formid string, formName string, workflowID int64) {

	result, err := db.Exec("INSERT INTO categories (categoryID,parentID,categoryName,categoryDescription,workflowID,sort,needToKnow,visible,disabled,type,lastModified) VALUES  (?,?,?,?,?,?,?,?,?,?,?)", formid, "", formName, "", workflowID, 0, 0, 1, 0, "", 0)
	if err != nil {
		log.Fatal("Can't insert category: ", err.Error())
	}

	result, err = db.Exec("INSERT INTO indicators (name,format,categoryID,required,sort,timeAdded,disabled,is_sensitive) VALUES  (?,?,?,?,?,?,?,?)", "Header", "", formid, 0, 0, "2024-05-21 12:59:17", 0, 0)
	if err != nil {
		log.Fatal("Can't insert indicator: ", err.Error())
	}

	headerIndicatorID, err := result.LastInsertId()
	if err != nil {
		log.Fatal("Can't receive last insert id: ", err.Error())
	}

	q := []string{"sillynames", "femaletitle", "maletitle", "titlerandomgender", "malefirstname", "femalefirstname", "lastname", "malename", "femalename", "namewithrandomgender", "email", "country", "language", "currency", "city", "state", "street", "address", "paragraph", "postalcode", "useragentstring", "fulldate", "phonenumber"}

	for _, fieldname := range q {
		result, err = db.Exec("INSERT INTO indicators (name,format,parentID,categoryID,required,sort,timeAdded,disabled,is_sensitive) VALUES  (?,?,?,?,?,?,?,?,?)", fieldname, "text", headerIndicatorID, formid, 0, 0, "2024-05-21 12:59:17", 0, 0)
		if err != nil {
			log.Fatal("Can't insert indicator: ", err.Error())
		}
	}
}

func addRecords(formid string, numberofrecords int) {

	var users []User

	rows, err := db.Query("SELECT userID,groupID FROM users WHERE active = ?", 1)
	if err != nil {
		log.Fatal("Cannot search for users: ", err.Error())
	}

	// Loop through rows, using Scan to assign column data to struct fields.
	for rows.Next() {
		var usr User
		if err := rows.Scan(&usr.UserID, &usr.GroupID); err != nil {
			log.Fatal("Cannot gather data for users: ", err.Error())
		}
		users = append(users, usr)
	}
	if err := rows.Err(); err != nil {
		log.Fatal("Cannot gather data for users: ", err.Error())
	}

	var indicators []Indicator

	rows, err = db.Query("SELECT indicatorID,name FROM indicators WHERE categoryID = ? AND format != ''", formid)
	if err != nil {
		log.Fatal("Cannot search for indicators: ", err.Error())
	}

	// Loop through rows, using Scan to assign column data to struct fields.
	for rows.Next() {
		var idr Indicator
		if err := rows.Scan(&idr.IndicatorID, &idr.Name); err != nil {
			log.Fatal("Cannot gather data for indicators: ", err.Error())
		}
		indicators = append(indicators, idr)
	}
	if err := rows.Err(); err != nil {
		log.Fatal("Cannot gather data for indicators: ", err.Error())
	}

	for _, user_row := range users {

		for i := 0; i < numberofrecords; i++ {
			result, err := db.Exec("INSERT INTO records (date,serviceID,userID,title,priority,lastStatus,submitted,deleted,isWritableUser,isWritableGroup) VALUES  (?,?,?,?,?,?,?,?,?,?)", time.Now().Unix(), 0, user_row.UserID, randomdata.SillyName(), 0, "Submitted", time.Now().Unix(), 0, 0, 1)
			if err != nil {
				log.Fatal("Can't insert record: ", err.Error())
			}

			recordID, err := result.LastInsertId()
			if err != nil {
				log.Fatal("Can't receive last insert id: ", err.Error())
			}

			result, err = db.Exec("INSERT INTO records_workflow_state (recordID,stepID) VALUES  (?,?)", recordID, 1)
			if err != nil {
				log.Fatal("Can't insert records_workflow_state: ", err.Error())
			}

			// need category_count
			result, err = db.Exec("INSERT INTO category_count (recordID,categoryID,count) VALUES  (?,?,?)", recordID, formid, 1)
			if err != nil {
				log.Fatal("Can't insert category_count: ", err.Error())
			}

			// i would really like to get the custom data as what I started this plan out with, for time sake I will just dump useragent since this appears to be the most data.

			query := "INSERT INTO data (recordID,indicatorID,series,data,timestamp,userID) VALUES "
			values := make([]interface{}, 0, len(indicators)*6)
			placeholders := make([]string, 0, len(indicators))
			for _, idr_row := range indicators {
				//placeholders[i] = "(?,?,?,?,?,?),"
				placeholders = append(placeholders, "(?,?,?,?,?,?)")
				values = append(values, recordID, idr_row.IndicatorID, 1, randomdata.UserAgentString(), time.Now().Unix(), user_row.UserID)
			}
			//query += fmt.Sprintf("%s", placeholders)
			//query = strings.TrimSuffix(query, ",")
			query += strings.Join(placeholders, ", ")

			//fmt.Printf("Albums found: %v\n", query)

			// Execute the query
			_, err = db.Exec(query, values...)
			if err != nil {
				log.Fatal("Can't insert record: ", err.Error())
			}
		}

	}
}
