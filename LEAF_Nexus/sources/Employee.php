<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Employee
    Date: August 15, 2011

*/

namespace Orgchart;

require_once 'Data.php';

class Employee extends Data
{
    public $debug = false;

    //     from main search triggers deep search)

    public $position;

    protected $dataTable = 'employee_data';

    protected $dataHistoryTable = 'employee_data_history';

    protected $dataTableUID = 'empUID';

    protected $dataTableDescription = 'Employee';

    protected $dataTableCategoryID = 1;

    private $log = array('<span style="color: red">Debug Log is ON</span>');    // error log for debugging

    private $tableName = 'employee';    // Table of employee contact info

    private $limit = 'LIMIT 3';       // Limit number of returned results "TOP 100"

    private $sortBy = 'lastName';          // Sort by... ?

    private $sortDir = 'ASC';           // Sort ascending/descending?

    private $maxStringDiff = 3;         // Max number of letter differences for a name (# of typos allowed)

    private $deepSearch = 3;           // Threshold for deeper search (min # of results before searching deeper)

    public function initialize()
    {
        $this->setDataTable($this->dataTable);
        $this->setDataHistoryTable($this->dataHistoryTable);
        $this->setDataTableUID($this->dataTableUID);
        $this->setDataTableDescription($this->dataTableDescription);
        $this->setDataTableCategoryID($this->dataTableCategoryID);
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

        $db_nat = new \DB(DIRECTORY_HOST, DIRECTORY_USER, DIRECTORY_PASS, DIRECTORY_DB);
        $login_nat = new Login($db_nat, $db_nat);

        require_once 'NationalEmployee.php';
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
     * @param int $empUID
     * @return bool
     */
    public function disableAccount($empUID)
    {
        if (!is_numeric($empUID))
        {
            return false;
        }
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            throw new Exception('Administrator access required to disable accounts');
        }

        $vars = array(':empUID' => $empUID,
                      ':time' => time(),
        );
        $res = $this->db->prepared_query('UPDATE employee
                                            SET deleted=:time
                                            WHERE empUID=:empUID', $vars);

        return true;
    }

    /**
     * Marks employee as not deleted
     * @param int $empUID
     * @return bool
     */
    public function enableAccount($empUID)
    {
        if (!is_numeric($empUID))
        {
            return false;
        }
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            throw new Exception('Administrator access required to enable accounts');
        }

        $vars = array(':empUID' => $empUID,
                ':time' => 0,
        );
        $res = $this->db->prepared_query('UPDATE employee
                                            SET deleted=:time
                                            WHERE empUID=:empUID', $vars);

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
     * @param int $positionID
     * @return array
     */
    public function getPositions($empUID)
    {
        $vars = array(':empUID' => $empUID);
        $res = $this->db->prepared_query('SELECT * FROM relation_position_employee
                                            WHERE empUID=:empUID', $vars);

        return $res;
    }

    public function lookupLogin($login)
    {
        $cacheHash = "lookupLogin{$login}";
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }
        $sql = "SELECT * FROM {$this->tableName}
                    WHERE userName = :login
                    	AND deleted = 0
                    {$this->limit}";

        $vars = array(':login' => $login);
        $result = $this->db->prepared_query($sql, $vars);

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

        $sql = "SELECT * FROM {$this->tableName}
                    WHERE empUID = :empUID
                    	AND deleted = 0";

        $vars = array(':empUID' => $empUID);
        $result = $this->db->prepared_query($sql, $vars);
        $resEmail = $this->db->prepared_query("SELECT data as email FROM {$this->dataTable}
                                                WHERE empUID=:empUID
                                                    AND indicatorID=6", $vars);
        if(isset($result[0]) && isset($resEmail[0])) {
            $result[0] = array_merge($result[0], $resEmail[0]);
        }

        $this->cache["lookupEmpUID_{$empUID}"] = $result;

        return $result;
    }

    public function lookupLastName($lastName)
    {
        $lastName = $this->parseWildcard($lastName);

        $sql = "SELECT * FROM {$this->tableName}
                    WHERE lastName LIKE :lastName
                    	AND deleted = 0
                    ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

        $vars = array(':lastName' => $lastName);
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0)
        {
            $sql = "SELECT * FROM {$this->tableName}
                WHERE phoneticLastName LIKE :lastName
                	AND deleted = 0
                ORDER BY {$this->sortBy} {$this->sortDir}
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

    public function lookupFirstName($firstName)
    {
        $firstName = $this->parseWildcard($firstName);

        $sql = "SELECT * FROM {$this->tableName}
                    WHERE firstName LIKE :firstName
                    	AND deleted = 0
                    ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

        $vars = array(':firstName' => $firstName);
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0)
        {
            $sql = "SELECT * FROM {$this->tableName}
                WHERE phoneticFirstName LIKE :firstName
                	AND deleted = 0
                ORDER BY {$this->sortBy} {$this->sortDir}
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
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";
        }
        else
        {
            $vars = array(':firstName' => $firstName, ':lastName' => $lastName);
            $sql = "SELECT * FROM {$this->tableName}
                WHERE firstName LIKE :firstName
                AND lastName LIKE :lastName
                AND deleted = 0
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";
        }
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0)
        {
            $sql = "SELECT * FROM {$this->tableName}
                        WHERE phoneticFirstName LIKE :firstName
                        AND phoneticLastName LIKE :lastName
                        AND deleted = 0
                        ORDER BY {$this->sortBy} {$this->sortDir}
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

    public function lookupEmail($email)
    {
        $sql = "SELECT * FROM {$this->dataTable}
    				LEFT JOIN {$this->tableName} USING (empUID)
    				WHERE indicatorID = 6
    					AND data = :email
    					AND deleted = 0
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
                                            LEFT JOIN groups USING (groupID)
                                            WHERE empUID=:empUID', $vars);

        return $res;
    }

    private function searchDeeper($input) {
        return $this->lookupByIndicatorID(23, $this->parseWildcard($input)); // search AD title
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
            case ($idx = strpos($input, ' ')) > 0:
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
            // Format: Loginname
            case strpos(strtolower($input), 'vha') !== false:
            case strpos(strtolower($input), 'vaco') !== false:
            case strpos(strtolower($input), 'userName:') !== false:
                   if ($this->debug)
                   {
                       $this->log[] = 'Format Detected: Loginname';
                   }
                   $searchResult = $this->lookupLogin($input);

                   break;
            // Format: Email
            case ($idx = strpos($input, '@')) > 0:
                   if ($this->debug)
                   {
                       $this->log[] = 'Format Detected: Email';
                   }
                   $searchResult = $this->lookupEmail($input);

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
                $res = $this->lookupLastName($input);
                // Check first names if theres few hits for last names
                if (count($res) <= $this->deepSearch)
                {
                    $this->log[] = 'Extra search on first names';
                    $res = array_merge($res, $this->lookupFirstName($input));
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
            require_once 'Position.php';
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
                        LEFT JOIN groups USING (groupID)
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
                    $finalResult[$currEmpUID]['positionData'] = $tdata[$searchResult[$i]['empUID']];
                    $finalResult[$currEmpUID]['serviceData'] = $position->getService($finalResult[$currEmpUID]['positionData']['positionID']);
                }
                $finalResult[$currEmpUID]['data'] = $this->getAllData($searchResult[$i]['empUID']);
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
