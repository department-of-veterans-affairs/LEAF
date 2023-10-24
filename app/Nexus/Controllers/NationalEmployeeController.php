<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    National Employee (mirror of Employee without write functions)
    Date: September 23, 2016

*/

namespace App\Nexus\Controllers;

use App\Nexus\Model\Employee;
use App\Nexus\Model\EmployeeData;
use App\Nexus\Model\Indicators;

class NationalEmployeeController extends NationalDataController
{
    public $debug = false;

    public $position;

    protected $dataTable = 'employee_data';

    protected $dataHistoryTable = 'employee_data_history';

    protected $dataTableUID = 'empUID';

    protected $dataTableDescription = 'Employee';

    protected $dataTableCategoryID = 1;

    private $cache = array();

    private $log = array('<span style="color: red">Debug Log is ON</span>');    // error log for debugging

    private $tableName = 'employee';    // Table of employee contact info

    private $limit = 'LIMIT 3';       // Limit number of returned results "TOP 100"

    private $sortDir = 'ASC';           // Sort ascending/descending?

    private $maxStringDiff = 3;         // Max number of letter differences for a name (# of typos allowed)

    private $deepSearch = 10;

    private $employee;

    // Threshold for deeper search (min # of results
    //     from main search triggers deep search)
    private $domain = '';

    public function __construct(Indicators $indicator, Employee $employee, EmployeeData $employeeData)
    {
        parent::__construct($indicator);
        $this->employee = $employee;
        $this->workingDataClass = $employeeData;
    }

    public function initialize()
    {
        $this->setDataTable($this->dataTable);
        $this->setDataHistoryTable($this->dataHistoryTable);
        $this->setDataTableUID($this->dataTableUID);
        $this->setDataTableDescription($this->dataTableDescription);
        $this->setDataTableCategoryID($this->dataTableCategoryID);
    }

    /**
     * @return void
     *
     * Created at: 10/12/2023, 8:18:56 AM (America/New_York)
     */
    public function setNoLimit(): void
    {
        $this->limit = 'LIMIT 100';
    }

    /**
     * Clean up all wildcards
     *
     * @param string $input
     *
     * @return string
     *
     * Created at: 10/12/2023, 8:19:16 AM (America/New_York)
     */
    public static function cleanWildcards(string $input): string
    {
        $input = str_replace('%', '*', $input);
        $input = str_replace('?', '*', $input);
        $input = preg_replace('/\*+/i', '*', $input);
        $input = preg_replace('/(\s)+/i', ' ', $input);
        $input = preg_replace('/(\*\s\*)+/i', '', $input);

        return $input;
    }

    /**
     * @param string $domain
     *
     * @return void
     *
     * Created at: 10/12/2023, 8:19:56 AM (America/New_York)
     */
    public function setDomain(string $domain): void
    {
        if ($domain != '') {
            $this->domain = $domain;
        }
    }

    /**
     * @param string $user_name
     *
     * @return array
     *
     * Created at: 10/12/2023, 9:22:53 AM (America/New_York)
     */
    public function lookupLogin(string $user_name): array
    {
        $cacheHash = "lookupLogin{$user_name}";

        if (!isset($this->cache[$cacheHash])) {
            $result = $this->employee->getEmployeeByUserName($user_name);

            if ($result['status']['code'] == 2) {
                $res_email = $this->workingDataClass->getEmail($result['data'][0]['empUID']);

                if ($res_email['status']['code'] == 2 && !empty($res_email['data'])) {
                    $result['data'][0] = array_merge($result['data'][0], $res_email['data'][0]);
                }
            }

            $this->cache[$cacheHash] = $result['data'];
        }

        return $this->cache[$cacheHash];
    }

    /**
     * @param int $empUID
     *
     * @return [type]
     *
     * Created at: 10/12/2023, 9:40:38 AM (America/New_York)
     */
    public function lookupEmpUID(int $empUID)
    {
        if (!isset($this->cache["lookupEmpUID_{$empUID}"])) {
            $result = $this->employee->getEmployeeByEmpUID($empUID);

            if ($result['status']['code'] == 2) {
                $res_email = $this->workingDataClass->getEmail($result['data'][0]['empUID']);

                if ($res_email['status']['code'] == 2 && !empty($res_email['data'])) {
                    $result['data'][0] = array_merge($result['data'][0], $res_email['data'][0]);
                }
            }

            $this->cache["lookupEmpUID_{$empUID}"] = $result['data'];
        }

        return $this->cache["lookupEmpUID_{$empUID}"];
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
        $disabled_clause = $disabled ?  " AND `deleted` = 0 "  : "";

        $vars = array(':lastName' => $lastName);
        $domain = $this->addDomain($vars);

        $result = $this->employee->getUsersByLastName($vars, $domain, $disabled_clause, 'lastName', $this->sortDir, $this->limit);

        if (empty($result['data'])) {
            $vars[':lastName'] = metaphone($lastName);

            if ($vars[':lastName'] != '') {
                $phonetic_result = $this->employee->getUsersByPhoneticLastName($vars, $domain, $disabled_clause, 'phoneticLastName', $this->sortDir, $this->limit);

                foreach ($phonetic_result['data'] as $res) {
                    if (levenshtein(strtolower($res['lastName']), trim(strtolower($lastName), '*')) <= $this->maxStringDiff) {
                        $result['data'][] = $res;
                    }
                }
            }
        }

        return $result['data'];
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
        $disabled_clause = $disabled ?  " AND `deleted` = 0 "  : "";

        $vars = array(':firstName' => $firstName);
        $domain = $this->addDomain($vars);

        $result = $this->employee->getUsersByFirstName($vars, $domain, $disabled_clause, 'lastName', $this->sortDir, $this->limit);

        if (empty($result['data'])) {
            $vars[':firstName'] = metaphone($firstName);

            if ($vars[':firstName'] != '') {
                $result = $this->employee->getUsersByPhoneticFirstName($vars, $domain, $disabled_clause, 'lastName', $this->sortDir, $this->limit);
            }
        }

        return $result['data'];
    }

    /**
     * @param string $lastName
     * @param string $firstName
     * @param string $middleName
     * @param bool $disabled
     *
     * @return array
     *
     * Created at: 10/12/2023, 10:50:42 AM (America/New_York)
     */
    public function lookupName(string $lastName, string $firstName, string $middleName = '', bool $disabled = false): array
    {
        $firstName = $this->parseWildcard($firstName);
        $lastName = $this->parseWildcard($lastName);
        $middleName = $this->parseWildcard($middleName);
        $disabled_clause = $disabled ?  " AND `deleted` = 0 "  : "";

        $vars = array(':firstName' => $firstName,
                    ':lastName' => $lastName,
                    ':middleName' => $middleName);
        $domain = $this->addDomain($vars);

        $result = $this->$this->employee->getUsersByWholeName($vars, $domain, $disabled_clause, 'lastName', $this->sortDir, $this->limit);

        if (empty($result['data'])) {
            $vars[':firstName'] = $this->metaphone_query($firstName);
            $vars[':lastName'] = $this->metaphone_query($lastName);
            unset($vars['middelName']);

            $result = $this->$this->employee->getUsersByWholeName($vars, $domain, 'lastName, phoneticLastName', $this->sortDir, $this->limit);
        }

        return $result['data'];
    }

    /**
     * @param string $email
     *
     * @return array
     *
     * Created at: 10/12/2023, 11:02:49 AM (America/New_York)
     */
    public function lookupEmail(string $email): array
    {
        $return_value = $this->workingDataClass->getUsersByIndicator($email, $this->limit, 6);

        return $return_value;
    }

    /**
     * @param string $phone
     *
     * @return array
     *
     * Created at: 10/12/2023, 11:02:59 AM (America/New_York)
     */
    public function lookupPhone(string $phone): array
    {
        $return_value = $this->workingDataClass->getUsersByIndicator($this->parseWildcard('*' . $phone), $this->limit, 5);

        return $return_value;
    }

    /**
     * @param int $indicatorID
     * @param string $query
     *
     * @return array
     *
     * Created at: 10/12/2023, 11:03:07 AM (America/New_York)
     */
    public function lookupByIndicatorID(int $indicatorID, string $query): array
    {
        $return_value = $this->workingDataClass->getUsersByIndicator($this->parseWildcard($query), $this->limit, $indicatorID);

        return $return_value;
    }

    /**
     * Runs additional search lookup by AD title to filter on larger sets of employees
     *
     * @param string $input
     *
     * @return array
     *
     * Created at: 10/12/2023, 11:04:49 AM (America/New_York)
     */
    private function searchDeeper(string $input): array
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

        if (strlen($input) > 3 && $this->limit != 'LIMIT 100') {
            $this->limit = 'LIMIT 5';
        }

        $searchResult = array();
        $first = '';
        $last = '';
        $middle = '';
        $input = trim($this->cleanWildcards($input));

        if ($input == '' || $input == '*') {
            return array(); // Special case to prevent retrieving entire list in one query
        }

        switch ($input) {
            // Format: search by indicatorID
            case $indicatorID != '':
                $searchResult = $this->lookupByIndicatorID($indicatorID, $input);

                break;
            // Format: Last, First
            case ($idx = strpos($input, ',')) > 0:
                if ($this->debug) {
                    $this->log[] = 'Format Detected: Last, First';
                }

                $last = trim(substr($input, 0, $idx));
                $first = trim(substr($input, $idx + 1));
                $midIdx = strpos($first, ' ');

                if ($midIdx > 0) {
                    $this->log[] = 'Detected possible Middle initial';
                    $middle = trim(trim(substr($first, $midIdx + 1)), '.');
                    $first = trim(substr($first, 0, $midIdx + 1));
                }

                $searchResult = $this->lookupName($last, $first, $middle);

                break;
            // Format: First Last
            case ($idx = strpos($input, ' ')) > 0 && strpos(strtolower($input), 'username:') === false:
                if ($this->debug) {
                    $this->log[] = 'Format Detected: First Last';
                }

                $first = trim(substr($input, 0, $idx));
                $last = trim(substr($input, $idx + 1));

                if (($midIdx = strpos($last, ' ')) > 0) {
                    $this->log[] = 'Detected possible Middle initial';
                    $middle = trim(trim(substr($last, 0, $midIdx + 1)), '.');
                    $last = trim(substr($last, $midIdx + 1));
                }

                $res = $this->lookupName($last, $first, $middle);

                // Check if the user reversed the names
                if (count($res) < $this->deepSearch) {
                    $this->log[] = 'Trying Reversed First/Last name';
                    $res = array_merge($res, $this->lookupName($first, $last));

                    // Try to look for service
                    if (count($res) == 0) {
                        $this->log[] = 'Trying Service search';
                        $input = trim('*' . $input);
                    }
                }

                $searchResult = $res;

                break;
            // Format: Email
            case ($idx = strpos($input, '@')) > 0:
                if ($this->debug) {
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
                if ($this->debug) {
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
                if ($this->debug) {
                    $this->log[] = 'Format Detected: Last OR First';
                }

                $res = $this->lookupAllUsersLastName($input, $includeDisabled);

                // Check first names if theres few hits for last names
                if (count($res) < $this->deepSearch) {
                    $this->log[] = 'Extra search on first names';
                    $res = array_merge($res, $this->lookupAllUsersFirstName($input, $includeDisabled));
                    // Try to look for service
                    if (count($res) == 0) {
                        $this->log[] = 'Trying Service search';
                        $input = trim('*' . $input);
                        //$res = array_merge($res, $this->lookupService($input));
                    }
                }

                $searchResult = $res;
        }

        // append org chart data
        $finalResult = array();
        $tcount = 0;

        if (!empty($searchResult)) {
            foreach ($searchResult as $employee) {
                $finalResult[$employee['empUID']] = $employee;
                $tcount++;
            }
            //error_log(print_r($searchResult, true));
            for ($i = 0; $i < $tcount; $i++) {
                $currEmpUID = $searchResult[$i]['empUID'];
                $finalResult[$currEmpUID]['data'] = $this->getAllData($searchResult[$i]['empUID']);
            }
            //error_log(print_r($finalResult, true));
        }

        return $finalResult;
    }

    /**
     * Translates the * wildcard to SQL % wildcard
     *
     * @param string $query
     *
     * @return string
     *
     * Created at: 10/12/2023, 11:11:00 AM (America/New_York)
     */
    private function parseWildcard(string $query): string
    {
        return str_replace('*', '%', $query . '*');
    }

    /**
     * @param string $in
     *
     * @return string
     *
     * Created at: 10/12/2023, 11:11:30 AM (America/New_York)
     */
    private function metaphone_query(string $in): string
    {
        return metaphone($in) . '%';
    }

    /**
     * @param array $vars
     *
     * @return string
     *
     * Created at: 10/12/2023, 11:11:43 AM (America/New_York)
     */
    private function addDomain(array &$vars): string
    {
        $return_value = '';

        if ($this->domain != '') {
            $vars[':domain'] = $this->domain;

            $return_value = 'AND domain = :domain';
        }

        return $return_value;
    }
}
