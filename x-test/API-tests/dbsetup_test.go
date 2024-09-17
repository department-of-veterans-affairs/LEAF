package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"
)

var origPortalDbName, origNexusDbName string
var origNexusDbNameForNexus string
var mysqlDSN = dbUsername + ":" + dbPassword + "@(" + dbHost + ")/?multiStatements=true"

// setupTestDB creates a predefined test database and reroutes the DB in a standard LEAF dev environment
func setupTestDB() {
	// Setup test database
	db, err := sql.Open("mysql", mysqlDSN)
	if err != nil {
		log.Fatal("Couldn't open database, check DSN: ", err.Error())
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		log.Fatal("Can't ping database: ", err.Error())
	}

	// Prep switchover to test DB
	f, err := os.ReadFile("database/portal_test_db.sql")
	if err != nil {
		log.Fatal("Couldn't open the file: ", err.Error())
	}
	importPortalSql := string(f)

	f, err = os.ReadFile("database/nexus_test_db.sql")
	if err != nil {
		log.Fatal("Couldn't open the file: ", err.Error())
	}
	importNexusSql := string(f)

	db.Exec("USE national_leaf_launchpad")

	// Get original DB config
	err = db.QueryRow(`SELECT portal_database, orgchart_database FROM sites
					WHERE site_path="/LEAF_Request_Portal"`).
		Scan(&origPortalDbName, &origNexusDbName)
	if err != nil {
		log.Fatal("Unable to read database: national_leaf_launchpad.sites. " + err.Error())
	}

	db.QueryRow(`SELECT orgchart_database FROM sites
					WHERE site_path="/LEAF_Request_Portal"`).
		Scan(&origNexusDbNameForNexus)

	// Load test DBs
	db.Exec("DROP DATABASE " + testPortalDbName)
	db.Exec("CREATE DATABASE " + testPortalDbName)
	db.Exec("USE " + testPortalDbName)
	db.Exec(importPortalSql)

	db.Exec("DROP DATABASE " + testNexusDbName)
	db.Exec("CREATE DATABASE " + testNexusDbName)
	db.Exec("USE " + testNexusDbName)
	db.Exec(importNexusSql)

	// Switch to test DB
	db.Exec("USE national_leaf_launchpad")

	_, err = db.Exec(`UPDATE sites
						SET portal_database = ?,
							orgchart_database = ?
						WHERE site_path="/LEAF_Request_Portal"`,
		testPortalDbName,
		testNexusDbName)
	if err != nil {
		log.Fatal("Could not update database: " + err.Error())
	}
	db.Exec(`UPDATE sites
				SET orgchart_database = ?
				WHERE site_path="/LEAF_Nexus"`,
		testNexusDbName)
}

func updateTestDBSchema() {
	fmt.Print("Updating DB Schema: Request Portal... ")
	res, _ := httpGet(RootURL + `scripts/updateDatabase.php`)
	if strings.Contains(res, `Db Update failed`) {
		log.Fatal(`Could not update Request Portal schema: ` + res)
	}
	fmt.Println("OK")

	fmt.Print("Updating DB Schema: Local Nexus (Orgchart)... ")
	res, _ = httpGet(RootOrgchartURL + `scripts/updateDatabase.php`)
	if strings.Contains(res, `Db Update failed`) {
		log.Fatal(`Could not update Nexus (Orgchart) schema: ` + res)
	}
	fmt.Println("OK")

	fmt.Print("Updating DB Schema: National Nexus (Orgchart)... ")
	res, _ = httpGet(NationalOrgchartURL + `scripts/updateDatabase.php`)
	if strings.Contains(res, `Db Update failed`) {
		log.Fatal(`Could not update Nexus (Orgchart) schema: ` + res)
	}
	fmt.Println("OK")
}

// teardownTestDB reroutes the standard LEAF dev environment back to the original configuration
func teardownTestDB() {
	db, err := sql.Open("mysql", mysqlDSN)
	if err != nil {
		log.Fatal("Can't connect to database: ", err.Error())
	}
	defer db.Close()

	// Switch back to original DB
	db.Exec("USE national_leaf_launchpad")

	_, err = db.Exec(`UPDATE sites
						SET portal_database = ?,
							orgchart_database = ?
						WHERE site_path="/LEAF_Request_Portal"`,
		origPortalDbName,
		origNexusDbName)
	if err != nil {
		log.Fatal("Could not update database: " + err.Error())
	}
	db.Exec(`UPDATE sites
				SET orgchart_database = ?
				WHERE site_path="/LEAF_Nexus"`,
		origNexusDbNameForNexus)
}
