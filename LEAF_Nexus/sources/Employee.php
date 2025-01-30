<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Employee
    Date: August 15, 2011

*/

namespace Orgchart;

use App\Leaf\Db;

class Employee extends Data
{
    public $debug = false;

    //     from main search triggers deep search

    public $position;

    protected $dataTable = 'employee_data';

    protected $dataHistoryTable = 'employee_data_history';

    protected $dataTableUID = 'empUID';

    protected $dataTableDescription = 'Employee';

    protected $dataTableCategoryID = 1;

    private $log = array('<span style="color: red">Debug Log is ON</span>');    // error log for debugging

    private $tableName = 'employee';    // Table of employee contact info

    private $limit = 'LIMIT 3';       // Limit number of returned results "TOP 100"

    private $sortDir = 'ASC';           // Sort ascending/descending?

    private $maxStringDiff = 3;         // Max number of letter differences for a name (# of typos allowed)

    private $deepSearch = 3;           // Threshold for deeper search (min # of results before searching deeper)

    private $portal_db;

    // the first value is the table, the second is the field. If the field is an array
    // the first value needs to be the field used for the where clause.
    private $disableUserNamePortalTables = array(
        'records' => 'userID',
        'service_chiefs' => array('userID', 'backupID'),
        'users' => array('userID', 'backupID')
    );

    public function initialize()
    {
        $this->setDataTable($this->dataTable);
        $this->setDataHistoryTable($this->dataHistoryTable);
        $this->setDataTableUID($this->dataTableUID);
        $this->setDataTableDescription($this->dataTableDescription);
        $this->setDataTableCategoryID($this->dataTableCategoryID);
        //$this->portal_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'Academy_Demo3');
    }

    public function setNoLimit()
    {
        $this->limit = 'LIMIT 100';
    }

    /**
     * Clean up all wildcards
     * @param string $input
     * @return string
     */
    public static function cleanWildcards($input)
    {
        $input = str_replace('%', '*', $input);
        $input = str_replace('?', '*', $input);
        $input = preg_replace('/\*+/i', '*', $input);
        $input = preg_replace('/(\s)+/i', ' ', $input);
        $input = preg_replace('/(\*\s\*)+/i', '', $input);

        return $input;
    }

    /**
     * @param string $user_name
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:28:22 PM (America/New_York)
     */
    public function refresh(string $user_name): array
    {
        $user_array = explode(',', htmlspecialchars_decode($user_name, ENT_QUOTES));
        // get employee data from national db
        // update employee data locally
        // if employee is inactive nationally for more than a week make inactive locally
        $global_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
        $national_emp = $this->getEmployeeByUserName($user_array, $global_db);

        if (!isset($national_emp['data'])) {
            $this->disableEmployees(explode(',', $user_name));

            $this->disablePortalTables();

            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'National Employee not found, employee disabled locally.'
                )
            );
        } else {
            $this->updateEmployeeByUserName($user_name, $national_emp['data'][0], $this->db);
            $local_emp = $this->getEmployeeByUserName($user_array, $this->db);
            $national_emp_data = $this->getEmployeeDataByEmpUID(explode(',', $national_emp['data'][0]['empUID']), $global_db);
            $this->updateEmployeeDataByEmpUID($local_emp['data'][0]['empUID'], $national_emp_data['data'], $this->db);
            $local_emp_data = $this->getEmployeeDataByEmpUID(explode(',', $local_emp['data'][0]['empUID']), $this->db);

            if ($this->isActiveNationally($national_emp)) {
                $return_value = array(
                    'status' => array(
                        'code' => 2,
                        'message' => ''
                    ),
                    'data' => array(
                        'user' => $local_emp['data'],
                        'user_data' => $local_emp_data['data']
                    )
                );
            } else {
                $this->disableEmployees(explode(',', $user_name));

                $this->disablePortalTables();

                $return_value = array(
                    'status' => array(
                        'code' => 4,
                        'message' => 'National Employee has been disabled for more than a week, employee has been disabled locally.'
                    )
                );
            }
        }

        return $return_value;
    }

    /**
     * @return array
     *
     * Created at: 6/9/2023, 2:28:32 PM (America/New_York)
     */
    public function refreshBatch(): array
    {
        $local_employee_list = $this->getAllEmployees($this->db);

        if (empty($local_employee_list)) {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'No employees returned.'
                )
            );
        } else {
            $local_employee_usernames = $this->formatUserNames($local_employee_list);

            $chunk_local_employee = array_chunk($local_employee_usernames, 100);

            $return_value = $this->processList($chunk_local_employee);
        }

        return $return_value;
    }

    /**
     * @param array $employee_list
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:28:40 PM (America/New_York)
     */
    private function formatUserNames(array $employee_list): array
    {
        $local_employee_usernames = [];

        foreach ($employee_list['data'] as $employee) {
            $local_employee_usernames[] = htmlspecialchars_decode($employee['userName'], ENT_QUOTES);
        }

        return $local_employee_usernames;
    }

    /**
     * @param array $employee_list
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:28:47 PM (America/New_York)
     */
    private function processList(array $employee_list): array
    {
        $results = [];

        foreach ($employee_list as $employee) {
            $results[] = $this->updateEmployeeDataBatch($employee);
        }

        $this->disablePortalTables();

        return $results;
    }

    /**
     * @param array $local_employees
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:28:56 PM (America/New_York)
     */
    private function updateEmployeeDataBatch(array $local_employees): array
    {
        $global_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);

        $national_employees_list = $this->getEmployeeByUserName($local_employees, $global_db);
        $local_employees_uid = $this->getEmployeeByUserName($local_employees, $this->db);

        $results = [];

        if (!empty($national_employees_list)) {
            $local_employee_array = $this->userNameUidList($local_employees_uid);

            $national_employee_uids = [];
            $local_array = [];
            $local_data_array = [];

            $this->prepareArrays($national_employee_uids, $local_array, $national_employees_list, $local_employee_array);

            $local_deleted_employees = array_diff(array_column($local_employees_uid['data'], 'userName'), array_column($national_employees_list['data'], 'userName'));

            if (!empty($local_deleted_employees)) {
                $results[] = $this->disableEmployees($local_deleted_employees);
            }

            if (!empty($local_array)) {
                $results[] = $this->batchEmployeeUpdate($local_array);
            }

            $national_employee_data = $this->getEmployeeDataByEmpUID($national_employee_uids, $global_db);

            $this->prepareDataArray($local_data_array, $national_employee_data, $local_employee_array);

            if (!empty($local_data_array)) {
                $results[] = $this->batchEmployeeDataUpdate($local_data_array);
            }

            $users = $this->updateNationalDisabledEmployees();

            if (!empty($users)) {
                $results[] = $this->disableEmployees($users);
            }
        }

        return $results;
    }

    private function updateNationalDisabledEmployees(): array
    {
        $vars = array();
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `deleted` > 0
                AND LEFT(`userName`, 9) <> "disabled_"';

        $res = $this->db->prepared_query($sql, $vars);

        $userNames = array();

        foreach ($res as $user) {
            $userNames[] = $user['userName'];
        }

        return $userNames;
    }

    private function disablePortalTables(): void
    {
        $disabledUsers = $this->getNewlyDisabledUsers();

        if (!empty($disabledUsers)) {
            $portal_db = $this->db;
            $portals = $this->getPortals();

            $sql = '';

            foreach ($this->disableUserNamePortalTables as $table => $field) {
                if (is_array($field)) {
                    foreach ($field as $fld) {
                        $sql .= 'UPDATE `' . $table .'`
                                SET `' . $fld . '` = :disabledUserName
                                WHERE `' . $fld . '` = :originalUserName;';
                    }

                } else {
                    $sql .= 'UPDATE `' . $table .'`
                            SET `' . $field . '` = :disabledUserName
                            WHERE `' . $field . '` = :originalUserName;';
                }
            }

            foreach ($portals as $portal) {
                $sql2 = 'USE ' . $portal['portal_database'];

                $portal_db->prepared_query($sql2, array());

                foreach ($disabledUsers as $user) {
                    // break down the userName to get original userName
                    $userName = explode('_', $user['userName']);

                    // Need to check if this user is in this portal, if not bypass
                    if ($userName[2] != '' && $this->checkUserToPortal($userName[2], $portal_db)) {
                        // update all tables with the new userName
                        $vars = array(':disabledUserName' => $user['userName'],
                                        ':originalUserName' => $userName[2]);

                        $portal_db->prepared_query($sql, $vars);
                    }
                }
            }
        }
    }

    private function checkUserToPortal(string $userName, Db $db): bool
    {
        $vars = array(':userName' => $userName);
        $sql = '';

        foreach ($this->disableUserNamePortalTables as $table => $field) {
            if ($sql !== '') {
                $sql .= ' UNION ';
            }

            if (is_array($field)) {
                $idx = 0;

                foreach ($field as $fld) {
                    if ($idx > 0) {
                        $sql .= ' UNION ';
                    }

                    $sql .= 'SELECT `userID`
                             FROM `' . $table .'`
                             WHERE `' . $fld . '` = :userName';

                    $idx++;
                }

            } else {
                $sql .= 'SELECT `userID`
                         FROM `' . $table .'`
                         WHERE `' . $field . '` = :userName';
            }
        }

        $result = $db->prepared_query($sql, $vars);

        if (count($result) > 0) {
            $return_value = true;
        } else {
            $return_value = false;
        }

        return $return_value;
    }

    private function enableAllPortalTables(string $userName): void
    {
        $portals = $this->getPortals();

        $userNameParts = explode('_', $userName);

        $vars = array(':disabledUserName' => $userName,
                        ':originalUserName' => $userNameParts[2]);
        $sql = '';

        foreach ($this->disableUserNamePortalTables as $table => $field) {
            if (is_array($field)) {
                foreach ($field as $fld) {
                    $sql .= 'UPDATE `' . $table .'`
                            SET `' . $fld . '` = :originalUserName
                            WHERE `' . $fld . '` = :disabledUserName;';
                }

            } else {
                $sql .= 'UPDATE `' . $table .'`
                        SET `' . $field . '` = :originalUserName
                        WHERE `' . $field . '` = :disabledUserName;';
            }
        }

        foreach ($portals as $portal) {
            $sql2 = 'USE ' . $portal['portal_database'];
            $this->portal_db->prepared_query($sql2, array());

            $this->portal_db->prepared_query($sql, $vars);
        }
    }

    private function getPortals(): array
    {
        // need to get the portals to update. Use ABSOLUTE_ORG_PATH to get all portals from
        // the sites table will need to strip https://domain
        $orgchart = str_replace('https://' . HTTP_HOST, '', ABSOLUTE_ORG_PATH);
        $launchpad_db = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, 'national_leaf_launchpad');

        $vars = array(':orgchartPath' => $orgchart);
        $sql = 'SELECT `portal_database`
                FROM `sites`
                WHERE `orgchart_path` = :orgchartPath
                AND `site_type` = "portal"
                AND (`portal_database` IS NOT NULL
                    OR `portal_database` <> "")';

        $return_value = $launchpad_db->prepared_query($sql, $vars);

        return $return_value;
    }

    private function getNewlyDisabledUsers(): array
    {
        $time_minus_24 = time() - 86400;

        $vars = array(':deleteTime' => $time_minus_24);
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `deleted` > :deleteTime';

        $return_value = $this->db->prepared_query($sql, $vars);

        return $return_value;
    }

    /**
     * @param array $local_employees_array
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:29:05 PM (America/New_York)
     */
    private function batchEmployeeUpdate(array $local_employees_array): array
    {
        $vars = array(
            'userName',
            'lastName',
            'firstName',
            'middleName',
            'phoneticFirstName',
            'phoneticLastName',
            'domain',
            'deleted',
            'lastUpdated'
        );

        if (!empty($local_employees_array)) {
            if ($this->db->insert_batch('employee', $local_employees_array, $vars)) {
                $return_value = array(
                    'status' => array(
                        'code' => 2,
                        'message' => ''
                    )
                );
            } else {
                $return_value = array(
                    'status' => array(
                        'code' => 4,
                        'message' => 'Database error, employees not updated'
                    )
                );
            }
        } else {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'No employees to update'
                )
            );
        }

        return $return_value;
    }

    /**
     * @param array $local_employees_data_array
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:29:12 PM (America/New_York)
     */
    private function batchEmployeeDataUpdate(array $local_employees_data_array): array
    {
        $vars = array(
            'indicatorID',
            'data',
            'author',
            'timestamp'
        );

        if (!empty($local_employees_data_array)) {
            if ($this->db->insert_batch('employee_data', $local_employees_data_array, $vars)) {
                $return_value = array(
                    'status' => array(
                        'code' => 2,
                        'message' => ''
                    )
                );
            } else {
                $return_value = array(
                    'status' => array(
                        'code' => 4,
                        'message' => 'Database error, employees not updated'
                    )
                );
            }
        } else {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'No employees to update'
                )
            );
        }

        return $return_value;
    }

    /**
     * @param array $deleted_employees
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:29:19 PM (America/New_York)
     */
    private function disableEmployees(array $deleted_employees): array
    {
        if (!empty($deleted_employees)) {
            $sql = "UPDATE `employee`
                    SET `deleted` = UNIX_TIMESTAMP(NOW()),
                        `userName` = concat('disabled_', `deleted`, '_',  `userName`)
                    WHERE `userName` IN (" . implode(",", array_fill(1, count($deleted_employees), '?')) . ")";

            $this->db->prepared_query($sql, array_values($deleted_employees));

            $return_value = array(
                'status' => array(
                    'code' => 2,
                    'message' => ''
                )
            );
        } else {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'There are no employees to delete.'
                )
            );
        }

        return $return_value;
    }

    private function enableEmployee(string $userName): void
    {
        // userName will be in the format of disabled_ts_userName.
        // This will need to be torn apart and only the userName kept.
        $userNameParts = explode('_', $userName);

        $vars = array(':userName' => $userNameParts[2],
                        ':disabledUserName' => $userName,
                        ':deletedTime' => 0);
        $sql = 'UPDATE `employee`
                SET `userName` = :userName,
                    `deleted` = :deletedTime
                WHERE `userName` = :disabledUserName';

        $this->db->prepared_query($sql, $vars);
    }

    /**
     * @param array $national_employee_uids
     * @param array $local_employee_array
     * @param array $national_list
     * @param array $local_list
     *
     * @return void
     *
     * Created at: 6/9/2023, 2:30:08 PM (America/New_York)
     */
    private function prepareArrays(array &$national_employee_uids, array &$local_employee_array, array $national_list, array $local_list): void
    {
        foreach ($national_list['data'] as $employee) {
            $national_employee_uids[] = (int) $employee['empUID'];

            $local_employee_array[] = [
                'empUID' => (empty($local_list[$employee['userName']]) ? null : $local_list[$employee['userName']]),
                'userName' => $employee['userName'],
                'lastName' => $employee['lastName'],
                'firstName' => $employee['firstName'],
                'middleName' => $employee['middleName'],
                'phoneticFirstName' => $employee['phoneticFirstName'],
                'phoneticLastName' => $employee['phoneticLastName'],
                'domain' => $employee['domain'],
                'deleted' => $employee['deleted'],
                'lastUpdated' => $employee['lastUpdated']
            ];
        }
    }

    /**
     * @param array $local_data_array
     * @param array $national_list
     * @param array $local_list
     *
     * @return void
     *
     * Created at: 6/9/2023, 2:30:17 PM (America/New_York)
     */
    private function prepareDataArray(array &$local_data_array, array $national_list, array $local_list): void
    {
        foreach ($national_list['data'] as $employee) {
            $local_data_array[] = [
                'empUID' => (empty($local_list[$employee['userName']]) ? null : $local_list[$employee['userName']]),
                'indicatorID' => $employee['indicatorID'],
                'data' => $employee['data'],
                'author' => $employee['author'],
                'timestamp' => $employee['timestamp'],
            ];
        }
    }

    /**
     * @param array $employee_list
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:30:29 PM (America/New_York)
     */
    private function userNameUidList(array $employee_list): array
    {
        $return_value = [];

        foreach ($employee_list['data'] as $employee) {
            $return_value[$employee['userName']] = $employee['empUID'];
        }

        return $return_value;
    }

    /**
     * @param Db $db
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:30:36 PM (America/New_York)
     */
    private function getAllEmployees(Db $db): array
    {
        $vars = array();
        $sql = 'SELECT LOWER(`userName`) AS `userName`
                FROM `employee`
                WHERE `userName` NOT LIKE "disabled_%"';

        $result = $db->prepared_query($sql, $vars);

        $return_value = array(
            'status' => array(
                'code' => 2,
                'message' => ''
            ),
            'data' => $result
        );

        return $return_value;
    }

    /**
     * @param array $user
     *
     * @return bool
     *
     * Created at: 6/9/2023, 2:30:52 PM (America/New_York)
     */
    private function isActiveNationally(array $user): bool
    {
        $weekOld = $user['data'][0]['lastUpdated'] + 604800;

        if (time() < $weekOld) {
            $return_value = true;
        } else {
            $return_value = false;
        }

        return $return_value;
    }

    /**
     * @param array $user_names
     * @param Db $db
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:31:07 PM (America/New_York)
     */
    public function getEmployeeByUserName(array $user_names, Db $db): array
    {
        $sql = "SELECT `empUID`, LOWER(`userName`) AS `userName`, `lastName`, `firstName`,
                    `middleName`, `phoneticLastName`, `phoneticFirstName`,
                    `domain`, `deleted`, `lastUpdated`
                FROM `employee`
                WHERE `userName` IN (" . implode(",", array_fill(1, count($user_names), '?')) . ")";
        $result = $db->prepared_query($sql, $user_names);

        $return_value = array(
            'status' => array(
                'code' => 2,
                'message' => ''
            ),
            'data' => $result
        );

        return $return_value;
    }

    /**
     * @param array $empUID
     * @param Db $db
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:31:14 PM (America/New_York)
     */
    private function getEmployeeDataByEmpUID(array $empUID, Db $db): array
    {
        $vars = array(':PHONEIID' => 5,
                ':EMAILIID' => 6,
                ':LOCATIONIID' => 8,
                ':ADTITLEIID' => 23
            );
        $sql = "SELECT `empUID`, `employee`.`userName`, `indicatorID`, `data`,
                    `author`, `timestamp`
                FROM `employee_data`
                LEFT JOIN `employee` USING (`empUID`)
                WHERE `empUID` IN ('" . implode("','", array_values($empUID)) . "')
                AND `indicatorID` IN (:PHONEIID,:EMAILIID,:LOCATIONIID,:ADTITLEIID)";
        $result = $db->prepared_query($sql, $vars);

        $return_value = array(
            'status' => array(
                'code' => 2,
                'message' => ''
            ),
            'data' => $result
        );

        return $return_value;
    }

    /**
     * @param string $user_name
     * @param array $national_user
     * @param Db $db
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:31:54 PM (America/New_York)
     */
    private function updateEmployeeByUserName(string $user_name, array $national_user, Db $db): array
    {
        $vars = array(
            ':userName' => $national_user['userName'],
            ':lastName' => $national_user['lastName'],
            ':firstName' => $national_user['firstName'],
            ':midInit' => $national_user['middleName'],
            ':phoneticFname' => $national_user['phoneticFirstName'],
            ':phoneticLname' => $national_user['phoneticLastName'],
            ':domain' => $national_user['domain'],
            ':deleted' => $national_user['deleted'],
            ':lastUpdated' => $national_user['lastUpdated'],
            ':localUserName' => $user_name
        );
        $sql = "UPDATE `employee`
                SET `userName` = :userName,
                    `lastName` = :lastName,
                    `firstName` = :firstName,
                    `middleName` = :midInit,
                    `phoneticFirstName` = :phoneticFname,
                    `phoneticLastName` = :phoneticLname,
                    `domain` = :domain,
                    `deleted` = :deleted,
                    `lastUpdated` = :lastUpdated
                WHERE `userName` = :localUserName";
        $result = $db->prepared_query($sql, $vars);

        $return_value = array(
            'status' => array(
                'code' => 2,
                'message' => ''
            ),
            'data' => $result
        );

        return $return_value;
    }

    /**
     * @param int $empUID
     * @param array $national_data
     * @param Db $db
     *
     * @return array
     *
     * Created at: 6/9/2023, 2:32:12 PM (America/New_York)
     */
    private function updateEmployeeDataByEmpUID(int $empUID, array $national_data, Db $db): array
    {
        $sql = "INSERT INTO `employee_data` (`empUID`, `indicatorID`, `data`,
                    `author`, `timestamp`)
                VALUES (:empUID, :indicatorID, :data, :author, :timestamp)
                ON DUPLICATE KEY UPDATE `data` = :data, `author` = :author,
                    `timestamp` = :timestamp";

        $return_value = array(
            'status' => array(
                'code' => 2,
                'message' => ''
            )
        );

        if (!empty($national_data)) {
            foreach($national_data as $data) {
                $vars = array(
                    ':empUID' => $empUID,
                    ':indicatorID' => $data['indicatorID'],
                    ':data' => $data['data'],
                    ':author' => $data['author'],
                    ':timestamp' => time()
                );
                $return_value['data'][] = $db->prepared_query($sql, $vars);
            }
        } else {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'There are no employees to delete.'
                )
            );
        }

        return $return_value;
    }

    /**
     * Add new employee
     * @param string $firstName
     * @param string $lastName
     * @param string $middleName
     * @param string $userName
     * @throws Exception
     * @return int New employee ID
     */
    public function addNew($firstName, $lastName, $middleName = '', $userName = '', $bypassAdmin = false)
    {
        if (strlen($firstName) == 0 || strlen($lastName) == 0)
        {
            throw new Exception('First and Last name must not be blank');
        }
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]) && !$bypassAdmin)
        {
            throw new Exception('Administrator access required to add new employees');
        }

        if ($userName == '')
        {
            $userName = 'NOACCOUNT-' . random_int(7, 9999999);
        }

        $vars = array(':firstName' => $this->sanitizeInput($firstName),
                      ':lastName' => $this->sanitizeInput($lastName),
                      ':middleName' => $this->sanitizeInput($middleName),
                      ':userName' => $this->sanitizeInput($userName),
                      ':phoFirstName' => metaphone($this->sanitizeInput($firstName)),
                      ':phoLastName' => metaphone($this->sanitizeInput($lastName)),
                      ':lastUpdated' => time(), );
        $this->db->prepared_query('INSERT INTO employee (firstName, lastName, middleName, userName, phoneticFirstName, phoneticLastName, lastUpdated, new_empUUID)
                                    VALUES (:firstName, :lastName, :middleName, :userName, :phoFirstName, :phoLastName, :lastUpdated, UUID())
                                    ON DUPLICATE KEY UPDATE deleted=0', $vars);

        $empUID = $this->lookupLogin($this->sanitizeInput($userName))[0]['empUID'];

        return $empUID == 0 ? 'Error adding employee. Already added?' : $empUID;
    }

    /**
     * Add new employee by importing from national DB
     * @param string $userName
     * @throws Exception
     * @return int New employee ID
     */
    public function importFromNational($userName)
    {
        $userName = htmlspecialchars_decode($userName,ENT_QUOTES);
        if ($userName == '')
        {
            return 'Invalid user';
        }

        // first see if the username already exists
        $local = $this->lookupLogin($userName);
        if (isset($local[0]))
        {
            return $local[0]['empUID'];
        }
        $cacheHash = "lookupLogin{$userName}";
        unset($this->cache[$cacheHash]);

        $db_nat = new Db(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
        $login_nat = new Login($db_nat, $db_nat);

        $natEmployee = new NationalEmployee($db_nat, $login_nat);

        $res = $natEmployee->lookupLogin($userName);
        if (isset($res[0]))
        {
            $res[0]['data'] = $natEmployee->getAllData($res[0]['empUID']);
        }

        try
        {
            $empUID = $this->addNew($res[0]['firstName'], $res[0]['lastName'], $res[0]['middleName'], $res[0]['userName'], true);

            if (is_numeric($empUID))
            {
                unset($_POST);
                $_POST['CSRFToken'] = $_SESSION['CSRFToken'];

                if ($res[0]['data'][5]['data'] != '')
                {
                    // Phone
                    $vars = array(':UID' => $empUID,
                                  ':indicatorID' => 5,
                                  ':data' => trim($res[0]['data'][5]['data']),
                                  ':timestamp' => time(),
                                  ':author' => 'imported', );
                    $this->db->prepared_query("INSERT INTO {$this->dataTable} ({$this->dataTableUID}, indicatorID, data, timestamp, author)
                                                        VALUES (:UID, :indicatorID, :data, :timestamp, :author)
                                                        ON DUPLICATE KEY UPDATE data=:data, timestamp=:timestamp, author=:author", $vars);
                }

                // Email
                $vars = array(':UID' => $empUID,
                              ':indicatorID' => 6,
                              ':data' => trim($res[0]['data'][6]['data']),
                              ':timestamp' => time(),
                              ':author' => 'imported', );
                $this->db->prepared_query("INSERT INTO {$this->dataTable} ({$this->dataTableUID}, indicatorID, data, timestamp, author)
                                                    VALUES (:UID, :indicatorID, :data, :timestamp, :author)
                                                    ON DUPLICATE KEY UPDATE data=:data, timestamp=:timestamp, author=:author", $vars);

                if ($res[0]['data'][8]['data'] != '')
                {
                    // Room
                    $vars = array(':UID' => $empUID,
                            ':indicatorID' => 8,
                            ':data' => trim($res[0]['data'][8]['data']),
                            ':timestamp' => time(),
                            ':author' => 'imported', );
                    $this->db->prepared_query("INSERT INTO {$this->dataTable} ({$this->dataTableUID}, indicatorID, data, timestamp, author)
                                                    VALUES (:UID, :indicatorID, :data, :timestamp, :author)
                                                    ON DUPLICATE KEY UPDATE data=:data, timestamp=:timestamp, author=:author", $vars);
                }

                if ($res[0]['data'][23]['data'] != '')
                {
                    // AD Title
                    $vars = array(':UID' => $empUID,
                                  ':indicatorID' => 23,
                                  ':data' => trim($res[0]['data'][23]['data']),
                                  ':timestamp' => time(),
                                  ':author' => 'imported', );
                    $this->db->prepared_query("INSERT INTO {$this->dataTable} ({$this->dataTableUID}, indicatorID, data, timestamp, author)
                                                    VALUES (:UID, :indicatorID, :data, :timestamp, :author)
                                                    ON DUPLICATE KEY UPDATE data=:data, timestamp=:timestamp, author=:author", $vars);
                }

                return $empUID;
            }
        }
        catch (Exception $e)
        {
            return $e->getMessage();
        }
    }

    /**
     * Marks employee as deleted
     * disabling a user requires that all instances of the userName be updated both in
     * orgchart and portals
     * @param int $empUID
     * @return bool
     */
    public function disableAccount($empUID)
    {
        if (!is_numeric($empUID)) {
            return false;
        }

        $memberships = $this->login->getMembership();

        if (!isset($memberships['groupID'][1])) {
            throw new Exception('Administrator access required to disable accounts');
        }

        $vars = array(':empUID' => $empUID);
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `empUID` = :empUID';

        $res = $this->db->prepared_query($sql, $vars);

        $this->disableEmployees(array($res[0]['userName']));

        $this->disablePortalTables();

        return true;
    }

    /**
     * Marks employee as not deleted
     * Enabling someone requires that all instances of the userName be updated in both
     * the orgchart and portals
     * @param int $empUID
     * @return bool
     */
    public function enableAccount($empUID)
    {
        if (!is_numeric($empUID)) {
            return false;
        }

        $memberships = $this->login->getMembership();

        if (!isset($memberships['groupID'][1])) {
            throw new Exception('Administrator access required to enable accounts');
        }

        $vars = array(':empUID' => $empUID,
                      ':time' => 0);
        $sql = 'UPDATE`employee`
                SET `deleted` = :time
                WHERE `empUID` = :empUID';

        $this->db->prepared_query($sql, $vars);

        $vars = array(':empUID' => $empUID);
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `empUID` = :empUID';

        $res = $this->db->prepared_query($sql, $vars);

        $this->enableEmployee($res[0]['userName']);
        $this->enableAllPortalTables($res[0]['userName']);

        return true;
    }

    /**
     * Get employee summary
     * @param int $positionID
     * @return array
     */
    public function getSummary($empUID)
    {
        $data = array();
        $vars = array(':empUID' => $empUID);
        $res = $this->db->prepared_query('SELECT * FROM employee
                                            LEFT JOIN relation_position_employee USING (empUID)
                                            WHERE empUID=:empUID', $vars);

        $data['employee'] = $res[0];
        $data['employee']['data'] = $this->getAllData($empUID);

        $data['employee']['positions'] = $this->getPositions($empUID);

        return $data;
    }

    /**
     * Get positions associated with an employee
     *
     * @param int|string $empUID
     * @return int|array|bool
     *
     * Created at: 1/19/2023, 10:22:32 AM (America/New_York)
     */
    public function getPositions(int|string $empUID): int|array|bool
    {
        $vars = array(':empUID' => $empUID);
        $sql = 'SELECT *
                FROM relation_position_employee
                WHERE empUID=:empUID';
        $res = $this->db->prepared_query($sql, $vars);

        return $res;
    }

    /**
     * Purpose: Get employee information for enabled or all accounts
     *
     * @param string $login
     * @param bool $searchDeleted
     */
    public function lookupLogin($login, bool $searchDeleted = false): array
    {
        $cacheHash = "lookupLogin{$login}";
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        $sqlVars = array(':login' => $login);
        $accountStatus = $searchDeleted ? '' : ' AND deleted = 0';
        $strSQL = "SELECT empUID, userName, lastName, firstName, middleName,
            phoneticFirstName, phoneticLastName, domain, deleted, lastUpdated, new_empUUID
            FROM {$this->tableName} WHERE userName = :login".$accountStatus;
        $result = $this->db->prepared_query($strSQL, $sqlVars);

        if (is_array($result) && isset($result[0]['empUID'])) {
            $sqlVars = array(':empUID' => $result[0]['empUID']);
            $strSQL = "SELECT data AS email FROM {$this->dataTable} WHERE empUID=:empUID AND indicatorID = 6";
            $resEmail = $this->db->prepared_query($strSQL, $sqlVars);
        }

        if(isset($result[0]) && isset($resEmail[0])) {
            $result[0] = array_merge($result[0], $resEmail[0]);
        }

        $this->cache[$cacheHash] = $result;

        return $result;
    }

    public function lookupEmpUID($empUID)
    {
        if (!is_numeric($empUID))
        {
            return array();
        }
        if (isset($this->cache["lookupEmpUID_{$empUID}"]))
        {
            return $this->cache["lookupEmpUID_{$empUID}"];
        }

        $strSQL = "SELECT empUID, userName, lastName, firstName, middleName, domain,
                        deleted, lastUpdated, new_empUUID, data as email FROM {$this->tableName}
                    LEFT JOIN employee_data USING (empUID)
                    WHERE empUID = :empUID
                        AND deleted = 0
                        AND indicatorID = 6";
        $sqlVars = array(':empUID' => $empUID);
        $result = $this->db->prepared_query($strSQL, $sqlVars);

        $this->cache["lookupEmpUID_{$empUID}"] = $result;

        return $result;
    }

    /**
     * get information used for portal data.metadata, action_history, notes and records.userMetadata fields
     * @param string $id - user identifier. could be an empUID (numeric string from data.data field) or a userName
     * @param bool $isEmpID - whether id is empUID (or userID)
     * */
    public function getInfoForUserMetadata(string $id, bool $isEmpID = true): ?string
    {
        $idType = $isEmpID === true ? 'empUID' : 'userName';
        $resMetadata = $isEmpID === true ? $this->lookupEmpUID($id) : $this->lookupLogin($id);

        $userMetadata = isset($resMetadata[0]) ?
            json_encode(
                array(
                    'firstName' => $resMetadata[0]['firstName'],
                    'lastName' => $resMetadata[0]['lastName'],
                    'middleName' => $resMetadata[0]['middleName'],
                    'email' => $resMetadata[0]['email'],
                    'userName' => $resMetadata[0]['userName'],
                )
            ) : null;
        return $userMetadata;
    }

    /**
     * Looks for all user's lastname
     *
     * @param string $lastName
     * @return array
     *
     * Created at: 1/18/2023, 2:17:23 PM (America/New_York)
     */
    public function lookupAllUsersLastName(string $lastName): array
    {
        $lastName = $this->parseWildcard($lastName);

        $sql = "SELECT *
                FROM {$this->tableName}
                WHERE lastName LIKE :lastName
                AND deleted = 0
                ORDER BY lastName {$this->sortDir}
                {$this->limit}";

        $vars = array(':lastName' => $lastName);
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0){
            $sql = "SELECT *
                    FROM {$this->tableName}
                    WHERE phoneticLastName LIKE :lastName
                    AND deleted = 0
                    ORDER BY phoneticLastName {$this->sortDir}
                    {$this->limit}";

            $vars = array(':lastName' => metaphone($lastName));
            if ($vars[':lastName'] != '')
            {
                $phoneticResult = $this->db->prepared_query($sql, $vars);

                foreach ($phoneticResult as $res)
                {  // Prune matches
                    if (levenshtein(strtolower($res['lastName']), trim(strtolower($lastName), '*')) <= $this->maxStringDiff)
                    {
                        $result[] = $res;
                    }
                }
            }
        }

        return $result;
    }

    /**
     * Looks for all user's firstname
     *
     * @param string $firstName
     * @return array
     *
     * Created at: 1/18/2023, 2:18:09 PM (America/New_York)
     */
    public function lookupAllUsersFirstName(string $firstName): array
    {
        $firstName = $this->parseWildcard($firstName);

        $sql = "SELECT *
                FROM {$this->tableName}
                WHERE firstName LIKE :firstName
                AND deleted = 0
                ORDER BY lastName {$this->sortDir}
                {$this->limit}";

        $vars = array(':firstName' => $firstName);
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0){
            $sql = "SELECT *
                    FROM {$this->tableName}
                    WHERE phoneticFirstName LIKE :firstName
                    AND deleted = 0
                    ORDER BY lastName {$this->sortDir}
                    {$this->limit}";

            $vars = array(':firstName' => metaphone($firstName));
            if ($vars[':firstName'] != '')
            {
                $phoneticResult = $this->db->prepared_query($sql, $vars);
                foreach ($phoneticResult as $res)
                {  // Prune matches
                    if (levenshtein(strtolower($res['firstName']), trim(strtolower($firstName), '*')) <= $this->maxStringDiff)
                    {
                        $result[] = $res;
                    }
                }
            }
        }

        return $result;
    }

    public function lookupName($lastName, $firstName, $middleName = '')
    {
        $firstName = $this->parseWildcard($firstName);
        $lastName = $this->parseWildcard($lastName);
        $middleName = $this->parseWildcard($middleName);

        $sql = '';
        $vars = array();
        if (strlen($middleName) > 1)
        {
            $vars = array(':firstName' => $firstName, ':lastName' => $lastName, ':middleName' => $middleName);
            $sql = "SELECT * FROM {$this->tableName}
                WHERE firstName LIKE :firstName
                AND lastName LIKE :lastName
                AND middleName LIKE :middleName
                AND deleted = 0
                ORDER BY lastName {$this->sortDir}
                {$this->limit}";
        }
        else
        {
            $vars = array(':firstName' => $firstName, ':lastName' => $lastName);
            $sql = "SELECT * FROM {$this->tableName}
                WHERE firstName LIKE :firstName
                AND lastName LIKE :lastName
                AND deleted = 0
                ORDER BY lastName {$this->sortDir}
                {$this->limit}";
        }
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0)
        {
            $sql = "SELECT * FROM {$this->tableName}
                        WHERE phoneticFirstName LIKE :firstName
                        AND phoneticLastName LIKE :lastName
                        AND deleted = 0
                        ORDER BY lastName, phoneticLastName {$this->sortDir}
                        {$this->limit}";

            $vars = array(':firstName' => $this->metaphone_query($firstName), ':lastName' => $this->metaphone_query($lastName));
            $phoneticResult = $this->db->prepared_query($sql, $vars);

            foreach ($phoneticResult as $res)
            {  // Prune matches
                if (levenshtein(strtolower($phoneticResult['lastName']), trim(strtolower($lastName), '*')) <= $this->maxStringDiff
                    && levenshtein(strtolower($phoneticResult['firstName']), trim(strtolower($firstName), '*')) <= $this->maxStringDiff)
                {
                    $result[] = $res;
                }
            }
        }

        return $result;
    }

    public function lookupEmail(string $email, bool $searchDisabledEmail = false): array
    {
        $accountStatus = $searchDisabledEmail ? '' : ' AND deleted = 0';
        $sql = "SELECT *
                FROM {$this->dataTable}
                LEFT JOIN {$this->tableName} USING (empUID)
                WHERE indicatorID = 6
                AND data = :email
                {$accountStatus}
                {$this->limit}";

        $vars = array(':email' => $email);

        return $this->db->prepared_query($sql, $vars);
    }

    public function lookupPhone($phone)
    {
        $sql = "SELECT * FROM {$this->dataTable}
                    LEFT JOIN {$this->tableName} USING (empUID)
                    WHERE indicatorID = 5
                        AND data LIKE :phone
                        AND deleted = 0
                        {$this->limit}";

        $vars = array(':phone' => $this->parseWildcard('*' . $phone));

        return $this->db->prepared_query($sql, $vars);
    }

    public function lookupByIndicatorID($indicatorID, $query)
    {
        $vars = array(':indicatorID' => $indicatorID,
                      ':query' => $this->parseWildcard($query),
        );

        $res = $this->db->prepared_query("SELECT * FROM {$this->dataTable}
                            LEFT JOIN {$this->tableName} USING ({$this->dataTableUID})
                            WHERE indicatorID = :indicatorID
                                AND data LIKE :query
                                AND deleted=0", $vars);

        return $res;
    }

    /**
     * Retrieve list of backup employees for a given employee
     * @param int $empUID
     */
    public function getBackups($empUID)
    {
        if (isset($this->cache["getBackups_{$empUID}"]))
        {
            return $this->cache["getBackups_{$empUID}"];
        }
        $vars = array(':empUID' => $empUID);
        $res = $this->db->prepared_query('SELECT * FROM relation_employee_backup
                                            LEFT JOIN employee ON
                                                relation_employee_backup.backupEmpUID = employee.empUID
                                            WHERE relation_employee_backup.empUID=:empUID', $vars);

        $this->cache["getBackups_{$empUID}"] = $res;

        return $res;
    }

    /**
     * Retrieve list of employees for which a given employee is a backup for
     * @param int $empUID
     */
    public function getBackupsFor($empUID)
    {
        if (!is_numeric($empUID))
        {
            return array();
        }
        if (isset($this->cache["getBackupsFor_{$empUID}"]))
        {
            return $this->cache["getBackupsFor_{$empUID}"];
        }
        $vars = array(':empUID' => $empUID);
        $res = $this->db->prepared_query('SELECT * FROM relation_employee_backup
                                            LEFT JOIN employee USING (empUID)
                                            WHERE relation_employee_backup.backupEmpUID=:empUID', $vars);

        $this->cache["getBackupsFor_{$empUID}"] = $res;

        return $res;
    }

    /**
     * Sets one employee to be the backup of another, and inheirts their access privileges
     * @param int $primaryEmpUID
     * @param int $backupEmpUID
     */
    public function setBackup($primaryEmpUID, $backupEmpUID)
    {
        if (!is_numeric($primaryEmpUID) || !is_numeric($backupEmpUID))
        {
            return false;
        }
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1])
            && !isset($memberships['employeeID'][$primaryEmpUID]))
        {
            throw new Exception('Administrator access required to add new employees');
        }

        $vars = array(':empUID' => $primaryEmpUID,
                      ':backupEmpUID' => $backupEmpUID,
                      ':approver' => $this->login->getUserID(), );
        $res = $this->db->prepared_query('INSERT INTO relation_employee_backup (empUID, backupEmpUID, approved, approverUserName)
                                            VALUES (:empUID, :backupEmpUID, 1, :approver)', $vars);

        return true;
    }

    /**
     * Removes an employee's backup
     * @param int $primaryEmpUID
     * @param int $backupEmpUID
     */
    public function removeBackup($primaryEmpUID, $backupEmpUID)
    {
        if (!is_numeric($primaryEmpUID) || !is_numeric($backupEmpUID))
        {
            return false;
        }
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1])
            && !isset($memberships['employeeID'][$primaryEmpUID]))
        {
            throw new Exception('Administrator access required to add new employees');
        }

        $vars = array(':empUID' => $primaryEmpUID,
                      ':backupEmpUID' => $backupEmpUID, );
        $res = $this->db->prepared_query('DELETE FROM relation_employee_backup
                                            WHERE empUID=:empUID AND backupEmpUID=:backupEmpUID', $vars);

        return true;
    }

    /**
     * List groups that the employee is a member of
     * @param int $empUID
     * @return array
     */
    public function listGroups($empUID)
    {
        $vars = array(':empUID' => $empUID);
        $res = $this->db->prepared_query('SELECT * FROM relation_group_employee
                                            LEFT JOIN `groups` USING (groupID)
                                            WHERE empUID=:empUID', $vars);

        return $res;
    }

    private function searchDeeper($input) {
        //return $this->lookupByIndicatorID(23, $this->parseWildcard($input)); // search AD title
        return []; // temporarily disable deep searches
    }

    public function search($input, $indicatorID = '')
    {
        $input = html_entity_decode($input, ENT_QUOTES);
        if (strlen($input) > 3 && $this->limit != 'LIMIT 100')
        {
            $this->limit = 'LIMIT 5';
        }
        $searchResult = array();
        $first = '';
        $last = '';
        $middle = '';
        $input = trim($this->cleanWildcards($input));
        if ($input == '' || $input == '*')
        {
            return array(); // Special case to prevent retrieving entire list in one query
        }
        switch ($input) {
            // Format: search by indicatorID
            case $indicatorID != '':
                $searchResult = $this->lookupByIndicatorID($indicatorID, $input);

                break;
            // Format: Last, First
            case ($idx = strpos($input, ',')) > 0:
                if ($this->debug)
                {
                    $this->log[] = 'Format Detected: Last, First';
                }
                $last = trim(substr($input, 0, $idx));
                $first = trim(substr($input, $idx + 1));

                if (($midIdx = strpos($first, ' ')) > 0)
                {
                    $this->log[] = 'Detected possible Middle initial';
                    $middle = trim(trim(substr($first, $midIdx + 1)), '.');
                    $first = trim(substr($first, 0, $midIdx + 1));
                }

                $searchResult = $this->lookupName($last, $first, $middle);
                if (count($searchResult) <= $this->deepSearch)
                {
                    $this->log[] = 'Trying Deeper search';
                    $input = trim('*' . $input);
                    $searchResult = array_merge($searchResult, $this->searchDeeper($input));
                }
                break;
            // Format: First Last
            case ($idx = strpos($input, ' ')) > 0 && strpos(strtolower($input), 'username:') === false:
                if ($this->debug)
                {
                    $this->log[] = 'Format Detected: First Last';
                }
                $first = trim(substr($input, 0, $idx));
                $last = trim(substr($input, $idx + 1));

                if (($midIdx = strpos($last, ' ')) > 0)
                {
                    $this->log[] = 'Detected possible Middle initial';
                    $middle = trim(trim(substr($last, 0, $midIdx + 1)), '.');
                    $last = trim(substr($last, $midIdx + 1));
                }
                $res = $this->lookupName($last, $first, $middle);
                // Check if the user reversed the names
                if (count($res) <= $this->deepSearch)
                {
                    $this->log[] = 'Trying Reversed First/Last name';
                    $res = array_merge($res, $this->lookupName($first, $last));
                    // Try to look for service
                    if (count($res) <= $this->deepSearch)
                    {
                        $this->log[] = 'Trying Deeper search';
                        $input = trim('*' . $input);
                        $res = array_merge($res, $this->searchDeeper($input));
                    }
                }
                $searchResult = $res;

                break;
            // Format: Email
            case ($idx = strpos($input, '@')) > 0:
                if ($this->debug)
                {
                    $this->log[] = 'Format Detected: Email';
                }

                if(substr(strtolower($input), 0, 15) === 'email.disabled:') {
                    $input = str_replace('email.disabled:', '', strtolower($input));
                    $searchResult = $this->lookupEmail($input, true);
                } else {
                    $searchResult = $this->lookupEmail($input);
                }

                break;
            // Format: Loginname
            case substr(strtolower($input), 0, 3) === 'vha':
            case substr(strtolower($input), 0, 4) === 'vaco':
            case substr(strtolower($input), 0, 3) === 'vba':
            case substr(strtolower($input), 0, 3) === 'cem':
            case substr(strtolower($input), 0, 3) === 'oit':
            case substr(strtolower($input), 0, 3) === 'vtr':
            case substr(strtolower($input), 0, 9) === 'username:':
                if ($this->debug)
                {
                    $this->log[] = 'Format Detected: Loginname';
                }
                $input = str_replace('username:', '', strtolower($input));
                $searchResult = $this->lookupLogin($input);

                break;
            //explicit search for disabled accounts
            case substr(strtolower($input), 0, 18) === 'username.disabled:':
                if ($this->debug)
                {
                    $this->log[] = 'Format Detected: Loginname (disabled)';
                }
                $input = str_replace('username.disabled:', '', strtolower($input));
                $searchResult = $this->lookupLogin($input, true);
                break;
            // Format: ID number
            case (substr($input, 0, 1) == '#') && is_numeric(substr($input, 1)):
                $searchResult = $this->lookupEmpUID(substr($input, 1));

                break;
            // Format: Phone number
            case is_numeric($input):
                $searchResult = $this->lookupPhone($input);

                break;
            // Format: Last or First
            default:
                if ($this->debug)
                {
                    $this->log[] = 'Format Detected: Last OR First';
                }
                $res = $this->lookupAllUsersLastName($input);
                // $res2 = $this->lookupLastName($input);

                // Check first names if theres few hits for last names
                if (count($res) <= $this->deepSearch)
                {
                    $this->log[] = 'Extra search on first names';
                    $res = array_merge($res, $this->lookupAllUsersFirstName($input));
                    // Try to look for service
                    if (count($res) <= $this->deepSearch)
                    {
                        $this->log[] = 'Trying Deeper search';
                        $input = trim('*' . $input);
                        $res = array_merge($res, $this->searchDeeper($input));
                    }
                }
                $searchResult = $res;
        }

        // append org chart data
        $finalResult = array();
        $position = null;
        if ($this->position != null)
        {
            $position = $this->position;
        }
        else
        {
            $position = new Position($this->db, $this->login);
        }

        if (count($searchResult) > 0)
        {

            $empUID_list = '';
            foreach ($searchResult as $employee)
            {
                $empUID_list .= $employee['empUID'] . ',';
                $finalResult[$employee['empUID']] = $employee;
            }
            $empUID_list = trim($empUID_list, ',');

            $sql = "SELECT *, positions.parentID AS parentID FROM relation_position_employee
                        LEFT JOIN positions USING (positionID)
                        LEFT JOIN relation_group_position USING (positionID)
                        LEFT JOIN `groups` USING (groupID)
                        WHERE empUID IN ({$empUID_list})";

            $vars = array();
            $result = $this->db->prepared_query($sql, $vars);

            $tdata = array();
            foreach ($result as $employeeData)
            {
                $tdata[$employeeData['empUID']] = $employeeData;
            }

            $tcount = count($searchResult);
            for ($i = 0; $i < $tcount; $i++)
            {
                $currEmpUID = $searchResult[$i]['empUID'];
                if (isset($tdata[$searchResult[$i]['empUID']]))
                {
                    //$finalResult[$currEmpUID]['positionData'] = $tdata[$currEmpUID];
                    $finalResult[$currEmpUID]['serviceData'] = $position->getService($tdata[$currEmpUID]['positionID']);
                }
                $finalResult[$currEmpUID]['data'] = $this->getAllData($currEmpUID);
            }

            // attach all the assigned positions
            foreach ($result as $employeeData){
                $finalResult[$employeeData['empUID']]['positionData'][] = $employeeData;
            }
        }
        return $finalResult;

    }

    // Translates the * wildcard to SQL % wildcard
    private function parseWildcard($query)
    {
        return str_replace('*', '%', $query . '*');
    }

    private function metaphone_query($in)
    {
        return metaphone($in) . '%';
    }
}
