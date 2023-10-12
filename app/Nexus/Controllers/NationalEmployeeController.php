<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    National Employee (mirror of Employee without write functions)
    Date: September 23, 2016

*/

namespace App\Nexus\Controllers;

class NationalEmployeeController extends NationalDataController
{
    public $debug = false;

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

    private $deepSearch = 10;

    private $cache;

    // Threshold for deeper search (min # of results
    //     from main search triggers deep search)
    private $domain = '';

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

    public function setDomain($domain)
    {
        if ($domain != '')
        {
            $this->domain = $domain;
        }
    }

    public function lookupLogin($login)
    {
        $cacheHash = "lookupLogin{$login}";
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        $sqlVars = array(':login' => $login);
	$strSQL = "SELECT * FROM {$this->tableName} WHERE userName = :login AND deleted = 0";
        $result = $this->db->prepared_query($strSQL, $sqlVars);

	$sqlVars = array(':empUID' => $result[0]['empUID']);
	$strSQL = "SELECT data AS email FROM {$this->dataTable} WHERE empUID=:empUID AND indicatorID = 6";
        $resEmail = $this->db->prepared_query($strSQL, $sqlVars);

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

        $strSQL = "SELECT * FROM {$this->tableName} WHERE empUID = :empUID AND deleted = 0";
        $sqlVars = array(':empUID' => $empUID);
        $result = $this->db->prepared_query($strSQL, $sqlVars);

	$strSQL = "SELECT data AS email FROM {$this->dataTable} WHERE empUID=:empUID AND indicatorID = 6";
        $resEmail = $this->db->prepared_query($strSQL, $sqlVars);

        if(isset($result[0]) && isset($resEmail[0])) {
            $result[0] = array_merge($result[0], $resEmail[0]);
        }

        $this->cache["lookupEmpUID_{$empUID}"] = $result;

        return $result;
    }

    /**
     * Looks for all user's lastname
     *
     * @param string $lastName
     * @param bool $disabled
     *
     * @return array
     *
     * Updated at: 1/25/2023, 12:44:32 PM (America/New_York)
     */
    public function lookupAllUsersLastName(string $lastName, bool $disabled): array
    {
        $lastName = $this->parseWildcard($lastName);
        $disabled_clause = $disabled ?  " AND deleted = 0 "  : "";

        $vars = array(':lastName' => $lastName);
        $domain = $this->addDomain($vars);
        $sql = "SELECT * FROM {$this->tableName}
                WHERE lastName LIKE :lastName {$domain}"
                . $disabled_clause .
                "ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";


        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0){
            $vars = array(':lastName' => metaphone($lastName));
            $domain = $this->addDomain($vars);
            $sql = "SELECT * FROM {$this->tableName}
                    WHERE phoneticLastName LIKE :lastName {$domain}"
                    . $disabled_clause .
                    "ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

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
          * Looks for all user's fistname
     *
     * @param string $firstName
     * @param bool $disabled
     *
     * @return array
     *
     * Updated at: 1/25/2023, 12:43:43 PM (America/New_York)
     */
    public function lookupAllUsersFirstName(string $firstName, bool $disabled): array
    {
        $firstName = $this->parseWildcard($firstName);
        $disabled_clause = $disabled ?  " AND deleted = 0 "  : "";

        $vars = array(':firstName' => $firstName);
        $domain = $this->addDomain($vars);
        $sql = "SELECT * FROM {$this->tableName}
                WHERE firstName LIKE :firstName {$domain}"
                . $disabled_clause .
                "ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";

        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0){
            $vars = array(':firstName' => metaphone($firstName));
            $domain = $this->addDomain($vars);
            $sql = "SELECT * FROM {$this->tableName}
                    WHERE phoneticFirstName LIKE :firstName {$domain}"
                    . $disabled_clause .
                    "ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

            if ($vars[':firstName'] != '')
            {
                $result = $this->db->prepared_query($sql, $vars);
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
            $domain = $this->addDomain($vars);
            $sql = "SELECT * FROM {$this->tableName}
                WHERE firstName LIKE :firstName
                AND lastName LIKE :lastName
                AND middleName LIKE :middleName
                AND deleted = 0
                {$domain}
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";
        }
        else
        {
            $vars = array(':firstName' => $firstName, ':lastName' => $lastName);
            $domain = $this->addDomain($vars);
            $sql = "SELECT * FROM {$this->tableName}
                WHERE firstName LIKE :firstName
                AND lastName LIKE :lastName
                AND deleted = 0
                {$domain}
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";
        }
        $result = $this->db->prepared_query($sql, $vars);

        if (count($result) == 0)
        {
            $vars = array(':firstName' => $this->metaphone_query($firstName), ':lastName' => $this->metaphone_query($lastName));
            $domain = $this->addDomain($vars);
            $sql = "SELECT * FROM {$this->tableName}
                        WHERE phoneticFirstName LIKE :firstName
                        AND phoneticLastName LIKE :lastName
                        AND deleted = 0
                        {$domain}
                        ORDER BY {$this->sortBy} {$this->sortDir}
                        {$this->limit}";

            $result = $this->db->prepared_query($sql, $vars);
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

        $domain = $this->addDomain($vars);
        $res = $this->db->prepared_query("SELECT * FROM {$this->dataTable}
    						LEFT JOIN {$this->tableName} USING ({$this->dataTableUID})
    						WHERE indicatorID = :indicatorID
    						AND data LIKE :query
    						{$domain}", $vars);

        return $res;
    }

    /**
     * Runs additional search lookup by AD title to filter on larger sets of employees
     *
     * @param string $input text of employee name to search
     * @return list of results from active directory query
     */
    private function searchDeeper($input)
    {
        return $this->lookupByIndicatorID(23, $this->parseWildcard($input)); // search AD title
    }


    /**
     * Search for users
     *
     * @param string $input
     * @param bool $includeDisabled
     *
     * @return array|bool
     *
     * Created at: 1/25/2023, 1:17:29 PM (America/New_York)
     */
    public function search(string $input, $indicatorID = '', bool $includeDisabled = false): array|bool
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
                $midIdx = strpos($first, ' ');

                if ($midIdx > 0)
                {
                    $this->log[] = 'Detected possible Middle initial';
                    $middle = trim(trim(substr($first, $midIdx + 1)), '.');
                    $first = trim(substr($first, 0, $midIdx + 1));
                }

                $searchResult = $this->lookupName($last, $first, $middle);

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
                if (count($res) < $this->deepSearch)
                {
                    $this->log[] = 'Trying Reversed First/Last name';
                    $res = array_merge($res, $this->lookupName($first, $last));
                    // Try to look for service
                    if (count($res) == 0)
                    {
                        $this->log[] = 'Trying Service search';
                        $input = trim('*' . $input);
                        //$res = array_merge($res, $this->lookupService($input));
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
                $searchResult = $this->lookupEmail($input);

                break;
            // Format: Loginname
            case substr(strtolower($input), 0, 3) === 'vha':
            case substr(strtolower($input), 0, 4) === 'vaco':
            case substr(strtolower($input), 0, 3) === 'vba':
            case substr(strtolower($input), 0, 3) === 'cem':
            case substr(strtolower($input), 0, 3) === 'oit':
            case substr(strtolower($input), 0, 9) === 'username:':
                if ($this->debug)
                {
                    $this->log[] = 'Format Detected: Loginname';
                }
                $input = str_replace('username:', '', strtolower($input));
                $searchResult = $this->lookupLogin($input);

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
                $res = $this->lookupAllUsersLastName($input, $includeDisabled);
                // Check first names if theres few hits for last names
                if (count($res) < $this->deepSearch)
                {
                    $this->log[] = 'Extra search on first names';
                    $res = array_merge($res, $this->lookupAllUsersFirstName($input, $includeDisabled));
                    // Try to look for service
                    if (count($res) == 0)
                    {
                        $this->log[] = 'Trying Service search';
                        $input = trim('*' . $input);
                        //$res = array_merge($res, $this->lookupService($input));
                    }
                }
                $searchResult = $res;
        }

        // append org chart data
        $finalResult = array();

        if (count($searchResult) > 0)
        {
            foreach ($searchResult as $employee)
            {
                $finalResult[$employee['empUID']] = $employee;
            }

            $tcount = count($searchResult);
            for ($i = 0; $i < $tcount; $i++)
            {
                $currEmpUID = $searchResult[$i]['empUID'];
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

    private function addDomain(&$vars)
    {
        if ($this->domain != '')
        {
            $vars[':domain'] = $this->domain;

            return 'AND domain = :domain';
        }

        return '';
    }
}
