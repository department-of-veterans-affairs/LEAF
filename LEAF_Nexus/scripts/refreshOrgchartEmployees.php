<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Refreshes employee data into local orgchart
*/

$currDir = dirname(__FILE__);

// Constant indicatorIDs for employee_data
define("PHONEIID", 5);
define("EMAILIID", 6);
define("LOCATIONIID", 8);
define("ADTITLEIID", 23);

include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../config.php';
include_once $currDir . '/../globals.php';
include_once $currDir . '/../sources/Login.php';

$config = new Orgchart\Config();
$db = new DB($config->dbHost, $config->dbUser, $config->dbPass, $config->dbName);
$phonedb = new DB(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
$login = new Orgchart\Login($phonedb, $db);
$login->loginUser();

$userName = $_GET['userName'];
$empUID = $_GET['empUID'];

// prevent updating if orgchart is the same
if (strtolower($config->dbName) == strtolower(DIRECTORY_DB)) {
    echo 1; // success value
} else {

	if(!empty($userName) && !empty($empUID)){

		updateUserInfo($userName, $empUID);
        echo 1;
	}else{

		$startTime = time();
		// echo "Refresh Orgchart Employees Start\n";

		updateLocalOrgchart();

		$endTime = time();
		// echo "Refresh Complete!\nCompletion time: " . date("U.v", $endTime-$startTime) . " seconds";
        echo 1; // success value
	}

}


/*
 *	Updates employee information from national orgchart to local orgchart
*/
function updateUserInfo($userName, $empUID){
	global $db, $phonedb;

	$vars = array(':userName' => $userName);
	$sql = "SELECT empUID, userName, lastName, firstName, middleName, phoneticLastName, phoneticFirstName, domain, deleted, lastUpdated
			FROM employee
			WHERE userName=:userName";

	$sql2 = "UPDATE employee
		SET lastName=:lastName,
		firstName=:firstName,
		middleName=:midInit,
		phoneticFirstName=:phoneticFname,
		phoneticLastName=:phoneticLname,
		domain=:domain,
		deleted=:deleted,
		lastUpdated=:lastUpdated
		WHERE userName=:userName";

	$res = $phonedb->prepared_query($sql, $vars);

	if (count($res) > 0) {
		$vars = array(
				':userName' => $res[0]['userName'],
				':lastName' => $res[0]['lastName'],
				':firstName' => $res[0]['firstName'],
				':midInit' => $res[0]['middleName'],
				':phoneticFname' => $res[0]['phoneticFirstName'],
				':phoneticLname' => $res[0]['phoneticLastName'],
				':domain' => $res[0]['domain'],
				':deleted' => $res[0]['deleted'],
				':lastUpdated' => $res[0]['lastUpdated']
		);

		// sets local employee table
		$db->prepared_query($sql2, $vars);

		// sets local employee_data table
		updateEmployeeData($res[0]['empUID'], $empUID);
	}
}

/*
 *	Updates employee information from national orgchart to local orgchart
*/
function updateLocalOrgchart()
{
    global $db, $phonedb;

    $localEmployees = getOrgchartEmployees();

    if (count($localEmployees) == 0) {
        return;
    }

    $userKeys = array_keys($localEmployees);

    $sql = "SELECT empUID, userName, lastName, firstName, middleName, phoneticLastName, phoneticFirstName, domain, deleted, lastUpdated
    		FROM employee
    		WHERE userName=:userName";

    $sql2 = "UPDATE employee
			SET lastName=:lastName,
			firstName=:firstName,
			middleName=:midInit,
			phoneticFirstName=:phoneticFname,
			phoneticLastName=:phoneticLname,
			domain=:domain,
			deleted=:deleted,
			lastUpdated=:lastUpdated
			WHERE userName=:userName";

    // update each employee entry
    foreach ($userKeys as $key) {
        $userNameArr = array('userName' => $localEmployees[$key]['userName']);

        // gets national data
        $res = $phonedb->prepared_query($sql, $userNameArr);

        if (count($res) > 0) {
            // echo 'Updating: ' . $res[0]['lastName'] . ', ' . $res[0]['firstName'] . "\n"; // name debugging
            $vars = array(
                ':userName' => $res[0]['userName'],
                ':lastName' => $res[0]['lastName'],
                ':firstName' => $res[0]['firstName'],
                ':midInit' => $res[0]['middleName'],
                ':phoneticFname' => $res[0]['phoneticFirstName'],
                ':phoneticLname' => $res[0]['phoneticLastName'],
                ':domain' => $res[0]['domain'],
                ':deleted' => $res[0]['deleted'],
                ':lastUpdated' => $res[0]['lastUpdated']
            );

            // sets local employee table
            $db->prepared_query($sql2, $vars);

            // sets local employee_data table
            updateEmployeeData($res[0]['empUID'], $localEmployees[$key]['empUID']);
        }
    }
}

/*
 *	Gets the employees from local employee table
 *  @return array of local employees
*/
function getOrgchartEmployees()
{
    global $db;

    $sql = "SELECT empUID, userName, lastName, firstName, middleName, phoneticLastName, phoneticFirstName, domain, deleted, lastUpdated FROM employee";

    $res = $db->query($sql);

    return $res;
}


/*
 *	Updates the individual indicators from national orgchart to local employee_data table. Emails, phone, etc
 *	@param int $nationalEmpUID
 *  @param int $localEmpUID
*/
function updateEmployeeData($nationalEmpUID, $localEmpUID)
{
    global $db, $phonedb;

    $sql = "SELECT empUID, indicatorID, data, author, timestamp FROM employee_data WHERE empUID=:nationalEmpUID AND indicatorID in (:PHONEIID,:EMAILIID,:LOCATIONIID,:ADTITLEIID)";

    $selectVars = array(
        ':nationalEmpUID' => $nationalEmpUID, 
        ':PHONEIID' => PHONEIID, 
        ':EMAILIID' => EMAILIID,
        ':LOCATIONIID' => LOCATIONIID,
        ':ADTITLEIID' => ADTITLEIID
    );

    $res = $phonedb->prepared_query($sql, $selectVars);

    if (count($res) > 0) {
        for ($i = 0; $i < count($res); $i++) {
            $sql2 = "INSERT INTO employee_data (empUID, indicatorID, data, author, timestamp)
				VALUES (:empUID, :indicatorID, :data, :author, :timestamp)
				ON DUPLICATE KEY UPDATE data=:data,
					author=:author,
					timestamp=:timestamp";

            $vars = array(
                ':empUID' => $localEmpUID,
                ':indicatorID' => $res[$i]['indicatorID'],
                ':data' => $res[$i]['data'],
                ':author' => $res[$i]['author'],
                ':timestamp' => time()
            );

            $db->prepared_query($sql2, $vars);
        }
    }
}
