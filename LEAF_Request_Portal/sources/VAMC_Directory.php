<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    VAMC_Directory
    Date Created: June 13, 2007

    + Queries an employee contact information database
    + Partial, Exact, Phonetic, Wildcard(*) matching
    + Detects names, email/phone/pager/room/service
    + Automatic supplemental and prepared queries
    + Sorts results
*/

namespace Portal;
use App\Leaf\Db;

class VAMC_Directory
{
    private $limit = 'LIMIT 100';         // Limit number of returned results "TOP 100"

    private $sortBy = 'Lname';          // Sort by... ?

    private $sortDir = 'ASC';           // Sort ascending/descending?

    private $deepSearch = 10;

    // Threshold for deeper search (min # of results
                                        //     from main search triggers deep search)
    private $maxStringDiff = 3;         // Max number of letter differences for a name (# of typos allowed)

    private $debug = false;             // Are we debugging?

    private $db;                        // The database object

    private $Employee;

    private $Group;

    private $tableName = 'Employee';    // Table of employee contact info

    private $tableDept = 'departments'; // Table of departments

    private $log = array('<span style="color: red">Debug Log is ON</span>');    // error log for debugging

    // Connect to the database
    public function __construct()
    {
        $oc_db = OC_DB;
        $login = new \Orgchart\Login($oc_db, $oc_db);
        $this->Employee = new \Orgchart\Employee($oc_db, $login);
        $this->Group = new \Orgchart\Group($oc_db, $login);
        $this->Group->setNoLimit();

        $this->Employee->setNoLimit();
    }

    public function __destruct()
    {
        if ($this->debug)
        {
            echo print_r($this->log) . '<br /><br />';
        }     // debugging
    }

    public function setDebugMode($switch)
    {
        $this->debug = $switch;
    }

    public function setSort($sortBy, $sortDir)
    {
        $this->sortBy = $sortBy;
        $this->sortDir = $sortDir;
    }

    // Raw Queries the database and returns an associative array
    // For debugging only
    public function query($sql)
    {
        if ($this->debug)
        {
            $res = $this->db->prepared_query($sql, array());
            if (is_object($res))
            {
                return $res->fetchAll(\PDO::FETCH_ASSOC);
            }
            $err = $this->db->errorInfo();
            $this->logError($err[2]);
        }
    }

    public function lookupEmpUID($empUID)
    {
        $res = $this->Employee->lookupEmpUID($empUID);
        $data = array();
        foreach ($res as $result)
        {
            $tdata = array();
            $tdata = $result;
            $tdata['Lname'] = $result['lastName'];
            $tdata['Fname'] = $result['firstName'];
            $tdata['Email'] = $result['email'];
            $data[] = $tdata;
        }

        return $data;
    }

    public function lookupLogin(
        string $login = "",
        bool $onlyGetName = false,
        bool $getGroups = false,
        bool $searchDeleted = false): array
    {
        $res = $this->Employee->lookupLogin($login, $searchDeleted);
        $data = array();
        foreach ($res as $result)
        {
            $tdata = array();
            $tdata = $result;
            $tdata['Lname'] = $result['lastName'];
            $tdata['Fname'] = $result['firstName'];

            if ($getGroups)
            {
                $tdata['groups'] = $this->Employee->listGroups($result['empUID']);
            }

            if (!$onlyGetName)
            {
                // orgchart data
                $ocData = $this->Employee->getAllData($result['empUID']);
                $tdata['Email'] = $ocData[6]['data'];
            }
            $data[] = $tdata;
        }

        return $data;
    }

    public function fuzzySearch($results)
    {
        if (count($results) > 30)
        {
            return $results;
        }

        $cache = array();
        $i = 0;

        foreach ($results as $result)
        {
            $keys = array_keys($result);
            foreach ($keys as $key)
            {
                $cache[$i][$key] = $result[$key];
            }
            $i++;
        }

        $count = $i;
        for ($i = 0; $i < $count; $i++)
        {
            if (isset($results[$i]))
            {
                $keys = array_keys($results[$i]);
                for ($j = $i; $j < $count; $j++)
                {
                    if ($j != $i)
                    {
                        $numFuzzyFind = 0;
                        foreach ($keys as $key)
                        {
                            if ($key == 'Phone' || $key == 'Pager')
                            {
                                if ($cache[$j][$key] != '')
                                {
                                    if (strpos(strtoupper($results[$i][$key]), strtoupper($cache[$j][$key])) !== false)
                                    {
//                                        echo $results[$i][$key] . ':: ' . $cache[$j][$key] . '***';
                                        $numFuzzyFind += $this->getUniqueness($key);
                                    }
                                }
                                if ($results[$i][$key] != '')
                                {
                                    if (strpos(strtoupper($cache[$j][$key]), strtoupper($results[$i][$key])) !== false)
                                    {
//                                        echo $results[$i][$key] . ':: ' . $cache[$j][$key] . '***';
                                        $numFuzzyFind += $this->getUniqueness($key);
                                    }
                                }
                            }
                        }
                        //echo $numFuzzyFind . '<br />';
                        if ($numFuzzyFind >= 2 && isset($results[$i]) && isset($results[$j]))
                        {
                            foreach ($keys as $key)
                            {
                                switch ($key) {
                                        case 'Fname':
                                            break;
                                        case 'Lname':
                                            break;
                                        case 'Mid_Initial':
                                            break;
                                        case 'Phone':
                                            $results[$i][$key] .= '<br /><b>Phone:</b> ' . $results[$j][$key];

                                            break;
                                        default:
                                            $results[$i][$key] .= '<br />' . $results[$j][$key];

                                            break;
                                    }
                                $results[$i][$key] = trim($results[$i][$key], '<br />');
                            }
                            unset($results[$j]);
                        }
                    }
                }
            }
        }

        return $results;
    }

    // All-in-one search function, returns array
    public function search($input)
    {
        $result = array();
        $orgChartResult = $this->Employee->search($input);

        $res_group = $this->Group->search(html_entity_decode($input));
        foreach ($res_group as $ocRes)
        {
            $tRes = array();
            $tRes = $ocRes;
            $tRes['Lname'] = $ocRes['groupTitle'];
            $tRes['Fname'] = '';
            $tRes['Email'] = '';
            $tRes['Phone'] = $ocRes['data'][24]['data'];
            $tRes['Mobile'] = '';
            $tRes['Title'] = '';
            $tRes['RoomNumber'] = $ocRes['data'][25]['data'];
            $tRes['Service'] = '';
            if ($tRes['Phone'] != ''
                || $tRes['RoomNumber'] != '')
            {
                $result[] = $tRes;
            }
        }

        // backwards compatible format
        foreach ($orgChartResult as $ocRes)
        {
            $tRes = array();
            $tRes = $ocRes;
            $tRes['Lname'] = $ocRes['lastName'];
            $tRes['Fname'] = $ocRes['firstName'];
            $tRes['Email'] = $ocRes['data'][6]['data'];
            $tRes['Phone'] = $ocRes['data'][5]['data'];
            $tRes['Mobile'] = $ocRes['data'][16]['data'];
            $tRes['Title'] = isset($ocRes['positionData']['positionTitle']) ? $ocRes['positionData']['positionTitle'] : $ocRes['data'][23]['data'];
            $tRes['RoomNumber'] = $ocRes['data'][8]['data'];
            $tRes['Service'] = isset($ocRes['serviceData'][0]) ? $ocRes['serviceData'][0]['groupTitle'] : '';
            $result[] = $tRes;
        }

        return $result;
    }

    // Log errors from the database
    private function logError($error)
    {
        $this->log[] = $error;
    }

    private function replaceAbbreviations($input)
    {
        $abbr = array('irm', 'mh', 'sw', 'pm&r');
        $full = array('information resource', 'mental health', 'social work', 'physical med');

        return str_replace($abbr, $full, $input);
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

    private function lookupName($lastName, $firstName, $middleName = '')
    {
        return $this->Employee->lookupName($lastName, $firstName, $middleName);
    }

    private function lookupNameByService($service, $firstName, $lastName = '')
    {
        $service = $this->parseWildcard($this->replaceAbbreviations($service));
        $firstName = $this->parseWildcard($firstName);
        $lastName = $this->parseWildcard($lastName);

        if ($lastName == '%')
        {
            $sql = "SELECT * FROM {$this->tableName}
                    WHERE Fname LIKE :firstName
                        AND Service LIKE :service
                    ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

            $query = $this->db->prepare($sql);
            $query->execute(array(':firstName' => $firstName, ':service' => $service));
            $result = $query->fetchAll(\PDO::FETCH_ASSOC);
            if (count($result) == 0)
            {
                $sql = "SELECT * FROM {$this->tableName}
                        WHERE Lname LIKE :firstName
                            AND Service LIKE :service
                        ORDER BY {$this->sortBy} {$this->sortDir}
                        {$this->limit}";

                $query = $this->db->prepare($sql);
                $query->execute(array(':firstName' => $firstName, ':service' => $service));
                $result = $query->fetchAll(\PDO::FETCH_ASSOC);
            }
        }
        else
        {
            $sql = "SELECT * FROM {$this->tableName}
                    WHERE PhoneticFname LIKE :firstName
                        AND PhoneticLname LIKE :lastName
                        AND Service LIKE :service
                    ORDER BY {$this->sortBy} {$this->sortDir}
                    {$this->limit}";

            $query = $this->db->prepare($sql);
            $query->execute(array(':firstName' => $this->metaphone_query($firstName),
                                  ':lastName' => $this->metaphone_query($lastName), ':service' => $service, ));
            $result = $query->fetchAll(\PDO::FETCH_ASSOC);
        }

        return $result;
    }

    private function lookupTitleByService($service, $title)
    {
        $service = $this->parseWildcard($this->replaceAbbreviations($service));
        $title = $this->parseWildcard($title);

        $sql = "SELECT * FROM {$this->tableName}
                WHERE Title LIKE :title
                    AND Service LIKE :service
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";

        $query = $this->db->prepare($sql);
        $query->execute(array(':title' => $title, ':service' => $service));
        $result = $query->fetchAll(\PDO::FETCH_ASSOC);

        return $result;
    }

    // Looks up the last name and returns an associative array
    private function lookupLastName($lastName)
    {
        return $this->Employee->lookupAllUsersLastName($lastName);
    }

    // Looks up the last name and returns an associative array
    private function lookupFirstName($firstName)
    {
        return $this->Employee->lookupAllUsersFirstName($firstName);
    }

    // Looks up phone or pager numbers
    private function lookupPhoneAndPager($phone)
    {
        $phone = $this->parseWildcard($phone);

        $sql = "SELECT * FROM {$this->tableName}
                WHERE Phone LIKE :phone
                    OR Pager LIKE :phone
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";

        $query = $this->db->prepare($sql);
        $query->execute(array(':phone' => $phone));
        $result = $query->fetchAll(\PDO::FETCH_ASSOC);

        return $result;
    }

    private function lookupRoom($room)
    {
        $room = $this->parseWildcard($room);

        $sql = "SELECT * FROM {$this->tableName}
                WHERE RoomNumber LIKE :room
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";

        $query = $this->db->prepare($sql);
        $query->execute(array(':room' => $room));
        $result = $query->fetchAll(\PDO::FETCH_ASSOC);

        return $result;
    }

    private function lookupEmail($email)
    {
        $email = $this->parseWildcard($email);

        $sql = "SELECT * FROM {$this->tableName}
                WHERE Email LIKE :email
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";

        $query = $this->db->prepare($sql);
        $query->execute(array(':email' => $email));
        $result = $query->fetchAll(\PDO::FETCH_ASSOC);

        return $result;
    }

    private function lookupService($service)
    {
        $service = $this->parseWildcard($service);

        $sql = "SELECT * FROM {$this->tableName}
                WHERE Service LIKE :service
                ORDER BY {$this->sortBy} {$this->sortDir}
                {$this->limit}";

        $query = $this->db->prepare($sql);
        $query->bindParam(':service', $service);
        $result = $query->fetchAll(\PDO::FETCH_ASSOC);
        if (count($result) == 0)
        {
            $service = strtolower($service);
            // Check abbreviations

            $service = $this->replaceAbbreviations($service);

            $query->execute();
            $result = $query->fetchAll(\PDO::FETCH_ASSOC);
        }

        return $result;
    }

    private function departmentSearch($searchQuery)
    {
        return array();
    }

    // Clean up all wildcards
    private function cleanWildcards($input)
    {
        $input = str_replace('%', '*', $input);
        $input = str_replace('?', '*', $input);
        $input = preg_replace('/\*+/i', '*', $input);
        $input = preg_replace('/(\s)+/i', ' ', $input);
        $input = preg_replace('/(\*\s\*)+/i', '', $input);

        return $input;
    }

    private function getUniqueness($key)
    {
        switch ($key) {
            case 'Phone':
                return 2;
            case 'Title':
                return 2;
            case 'RoomNumber':
                return 2;
            case 'Pager':
                return 2;
            default:
                return 1;
        }
    }
}
