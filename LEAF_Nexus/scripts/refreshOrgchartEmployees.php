<?php
use App\Leaf\Db;
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

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$globalDB = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);

$oc_login->loginUser();

// prevent updating if orgchart is the same
if (strtolower($oc_config->dbName) == strtolower(DIRECTORY_DB)) {
    echo 1; // success value
} else {

    if (!empty($_GET['userName']) && !empty($_GET['empUID'])) {
        updateUserInfo($_GET['userName'], $_GET['empUID']);
        echo 1;
    } else {

        $startTime = time();
        // echo "Refresh Orgchart Employees Start\n";
        updateLocalOrgchartBatch();

        $endTime = time();
        // echo "Refresh Complete!\nCompletion time: " . date("U.v", $endTime-$startTime) . " seconds";
        echo 1; // success value
    }
}

/*
 *	Updates single employee information from national orgchart to local orgchart
 *
 * @param string $userName
 * @param int $empUID
 */
function updateUserInfo(string $userName, int $empUID)
{
    global $db, $globalDB, $oc_db;

    $vars = array(':userName' => htmlspecialchars_decode($userName, ENT_QUOTES)); //for users with apostrophe in name

    $sql = "SELECT empUID, userName, lastName,
            firstName, middleName, phoneticLastName,
            phoneticFirstName, domain, deleted, lastUpdated
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

    #used to disable if not found in national
    $sql3 = "UPDATE employee
            SET deleted=:deleted
            WHERE userName=:userName";

    $sql4 = "SELECT userName, deleted, lastUpdated
             FROM employee
             WHERE userName=:userName AND lastUpdated > 0";

    $res = $globalDB->prepared_query($sql, $vars);

    if (count($res) == 0) {
        //if there is no record in nat, disable the account.
        $vars = array(
            ':userName' => $userName,
            ':deleted' => time()
        );
	    $oc_db->prepared_query($sql3, $vars);
    }

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
		$oc_db->prepared_query($sql2, $vars);

        // sets local employee_data table
        updateEmployeeData($res[0]['empUID'], $empUID);

        $currentTime = time();
        $oneWeekAdded = $res[0]['lastUpdated'] + 604800;

        if ($currentTime > $oneWeekAdded) {
            // user is disabled if userUpdated is lower than the current time
            $vars = array(
                ':deleted' => $currentTime,
                ':userName' => $userName
            );
            $sql = "UPDATE employee
                SET deleted=:deleted
                WHERE userName=:userName";

            $db->prepared_query($sql4, $vars);
        }
    }
}

function updateLocalOrgchartBatch()
{
    global $oc_db, $globalDB;

    // replace the separate function for getting employee
    $localEmployeeSql = "SELECT userName FROM employee";
    $localEmployees = $oc_db->query($localEmployeeSql);

    if (count($localEmployees) == 0) {
        return;
    }

    $localEmployeeUsernames = [];

    // could we use a sub query? yes however if there are large amounts of data, I want to limit the bleeding a bit.
    foreach ($localEmployees as $employee) {
        $localEmployeeUsernames[] = htmlspecialchars_decode($employee['userName'], ENT_QUOTES);
    }

    // chunk it so we can go over this data.
    $localEmployeeUsernamesChunked = array_chunk($localEmployeeUsernames, 100);

    // loop over the chunked names so we can limit how much data this will be inserting at a time.
    foreach ($localEmployeeUsernamesChunked as $localEmployeeUsernames) {
        // get employees from the nexus based on the username
        updateEmployeeDataBatch($localEmployeeUsernames);
    }
}
/**
 * @param getEmployeeUIDs array $localEmployeeUsernames
 * @return [$localEmpUIDs,$localEmpArray]
 */
function getEmployeeUIDs(array $localEmployeeUsernames): array {
    global $oc_db;

    // get local empuids, need to gather employees that have been added. 
    $localEmployeeImplode = implode(",",array_fill(1, count($localEmployeeUsernames), '?'));
    $localEmployeeSql = "SELECT empUID, userName FROM employee WHERE userName IN (". $localEmployeeImplode .")";
    $localEmpUIDs = $oc_db->prepared_query($localEmployeeSql,$localEmployeeUsernames);

    $localEmpArray = [];
    foreach ($localEmpUIDs as $localUsername) {
        $localEmpArray[$localUsername['userName']] = $localUsername['empUID'];
    }

    return [$localEmpUIDs,$localEmpArray];
}

function updateEmployeeDataBatch(array $localEmployeeUsernames = [])
{

    global $oc_db, $globalDB;

    if (empty($localEmployeeUsernames)) {
        return FALSE;
    }

    // you will need to gather the emp ids since we need to grab local data as well.
    $nationalEmpUIDs = [];

    // you will need to store the data for updating the batch of employees
    $localEmployeeArray = [];
    // as well as data
    $localEmployeeDataArray = [];

    // STEP 1: Get the employees updated
    // get org employees
    $orgEmployeeImplode = implode(",", array_fill(1, count($localEmployeeUsernames), '?'));
    $orgEmployeeSql = "SELECT empUID, userName, lastName, firstName, middleName, phoneticLastName, phoneticFirstName, domain, deleted, lastUpdated
    		FROM employee
    		WHERE userName IN (" . $orgEmployeeImplode . ")";

    $orgEmployeeRes = $globalDB->prepared_query($orgEmployeeSql, $localEmployeeUsernames);

    // get local empuids
    list($localEmpUIDs,$localEmpArray) = getEmployeeUIDs($localEmployeeUsernames);

    //if for some reason there is no data, we need to stop right there.
    if (empty($orgEmployeeRes)) {
        return FALSE;
    }
    
    foreach ($orgEmployeeRes as $orgEmployee) {

        $nationalEmpUIDs[] = (int) $orgEmployee['empUID'];

        $localEmployeeArray[] = [
            'empUID' => (empty($localEmpArray[$orgEmployee['userName']]) ? null : $localEmpArray[$orgEmployee['userName']]),
            'userName' => $orgEmployee['userName'],
            'lastName' => $orgEmployee['lastName'],
            'firstName' => $orgEmployee['firstName'],
            'middleName' => $orgEmployee['middleName'],
            'phoneticFirstName' => $orgEmployee['phoneticFirstName'],
            'phoneticLastName' => $orgEmployee['phoneticLastName'],
            'domain' => $orgEmployee['domain'],
            'deleted' => $orgEmployee['deleted'],
            'lastUpdated' => $orgEmployee['lastUpdated']
        ];
    }

    $localDeletedEmployees = array_diff(array_column($localEmpUIDs, 'userName'), array_column($orgEmployeeRes, 'userName'));
    $deletedEmployeesImplode = implode(",", array_fill(1, count($localDeletedEmployees), '?'));
    $deletedEmployeesSql = "UPDATE employee SET deleted=UNIX_TIMESTAMP(NOW()) WHERE userName IN (" . $deletedEmployeesImplode . ")";

    if (!empty($localDeletedEmployees)) {
        $oc_db->prepared_query($deletedEmployeesSql,array_values($localDeletedEmployees));
    }

    $oc_db->insert_batch('employee',$localEmployeeArray,['lastName','firstName','middleName','phoneticFirstName','phoneticLastName','domain','deleted','lastUpdated']);

    // STEP 2: Get employee_data updated
    // get the employee data, we will need to get the employee ids first

    $orgEmployeeDataSql = "SELECT empUID, employee.userName, indicatorID, data, author, timestamp
    				FROM employee_data
				LEFT JOIN employee USING (empUID)
				WHERE empUID IN ('" . implode("','", $nationalEmpUIDs) . "') AND indicatorID IN (:PHONEIID,:EMAILIID,:LOCATIONIID,:ADTITLEIID)";

    $orgEmployeeDataVars = [
        ':PHONEIID' => PHONEIID,
        ':EMAILIID' => EMAILIID,
        ':LOCATIONIID' => LOCATIONIID,
        ':ADTITLEIID' => ADTITLEIID
    ];

    $orgEmployeeDataRes = $globalDB->prepared_query($orgEmployeeDataSql, $orgEmployeeDataVars);

    if (empty($orgEmployeeDataRes)) {
        return FALSE;
    }

    // regather employee data since we may have inserted items
    list($localEmpUIDs,$localEmpArray) = getEmployeeUIDs($localEmployeeUsernames);

    foreach ($orgEmployeeDataRes as $orgEmployeeData) {

        // if this user is not found, we will skip adding data for them.
        if (empty($localEmpArray[$orgEmployeeData['userName']])) {
            continue;
        }
        else
        {
            $localEmployeeDataArray[] = [
                'empUID' => $localEmpArray[$orgEmployeeData['userName']],
                'indicatorID' => $orgEmployeeData['indicatorID'],
                'data' => $orgEmployeeData['data'],
                'author' => $orgEmployeeData['author'],
                'timestamp' => $orgEmployeeData['timestamp'],
            ];
        }

        
    }

    // make sure data array has data before attempting to insert data
    if (!empty($localEmployeeDataArray)) {
        $oc_db->insert_batch('employee_data',$localEmployeeDataArray,['indicatorID','data','author','timestamp']);
    }

}

/*
 *	Updates the individual indicators from national orgchart to local employee_data table. Emails, phone, etc
 *	@param int $nationalEmpUID
 *  @param int $localEmpUID
*/
function updateEmployeeData($nationalEmpUID, $localEmpUID)
{
    global $oc_db, $globalDB;

    $sql = "SELECT empUID, indicatorID, data, author, timestamp
            FROM employee_data
            WHERE empUID=:nationalEmpUID
            AND indicatorID
            IN (:PHONEIID,:EMAILIID,:LOCATIONIID,:ADTITLEIID)";

    $selectVars = array(
        ':nationalEmpUID' => $nationalEmpUID,
        ':PHONEIID' => PHONEIID,
        ':EMAILIID' => EMAILIID,
        ':LOCATIONIID' => LOCATIONIID,
        ':ADTITLEIID' => ADTITLEIID
    );

    $res = $globalDB->prepared_query($sql, $selectVars);

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

            $oc_db->prepared_query($sql2, $vars);
        }
    }
}
