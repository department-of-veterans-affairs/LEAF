<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    VAMC_directory_maintenance
    Date Created: June 13, 2007

    + Imports data into an employee contact information database
    + Multiple data sources
    + Buffered inserts for low memory usage
*/

namespace Portal;

class VAMC_Directory_maintenance_AD
{
    /**
     * @var string
     */
    private $sortBy = 'Lname';          // Sort by... ?

    /**
     * @var string
     */
    private $sortDir = 'ASC';           // Sort ascending/descending?

    /**
     * @var bool
     */
    private $debug = true;             // Are we debugging?

    /**
     * @var \DB
     */
    private $db;                        // The database object

    /**
     * @var string
     */
    private $tableName = 'Employee';    // Table of employee contact info

    /**
     * @var array
     */
    private $log = array('Debug Log is ON');          // error log for debugging

    /**
     * @var int
     */
    private $time;

    /**
     * @var array
     */
    private $users = array();

    /**
     * Connect to the database
     * @param string $currDir
     */
    public function __construct()
    {
        $this->time = time();
        $currDir = dirname(__FILE__);

        try
        {
            $this->db = \OC_DB;
            /* $this->db = new \PDO(
                "mysql:host=".\DIRECTORY_HOST.";dbname={$config->phonedbName}",
                            \DIRECTORY_USER,
                \DIRECTORY_PASS,
                array(\PDO::ATTR_PERSISTENT => true)
            );
            unset($config); */
        }
        catch (\PDOException $e)
        {
            echo 'Database Error: ' . $e->getMessage();
            exit();
        }
    }

    /**
     * @todo is this correct?
     */
    public function __destruct()
    {
        if ($this->debug)
        {
            echo print_r($this->log);
        }     // debugging
    }

    /**
     * @param string $sortBy
     * @param string $sortDir
     *
     * @return void
     */
    public function setSort($sortBy, $sortDir): void
    {
        $this->sortBy = $sortBy;
        $this->sortDir = $sortDir;
    }

    /**
     * Raw Queries the database and returns an associative array
     * For debugging only
     * @param string $sql
     *
     * @return void
     */
    public function query($sql):void
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

    //
    /**
     * Imports data from ^ and \n delimited file of format:
     * @param string $file
     *
     * @return string
     * @todo refactor so that there is a return for all code paths
     */
    public function importVistaData($file): string
    {
        $rawdata = file($file);
        $count = 0;

        foreach ($rawdata as $line)
        {
            $t = explode('^', $line);
            array_walk($t, array($this, 'trimField'));
            if (!is_array($t))
            {
                return 'invalid service';
            }

//            $tmpName = explode(',', $t[0]);
            $lname = isset($t[0]) ? $t[0] : null;
//            $tmp = explode(' ', $tmpName[1]);
            $fname = isset($t[1]) ? $t[1] : null;
            $midIni = isset($t[2]) ? $t[2] : null;
            $email = isset($t[93]) ? $t[93] : null;
            $phone = isset($t[5]) ? $t[5] : null;
            $pager = isset($t[6]) ? $t[6] : null;
            $roomNum = isset($t[7]) ? str_replace('-', '', $t[7]) : null;
//            $title = $t[1] ? $this->ucwordss($t[1]) : null;
//            $service = $t[5] ? $this->ucwordss($t[5]) : null;
            $title = isset($t[3]) ? $t[3] : null;
            $service = isset($t[4]) ? $t[4] : null;
            $mailcode = isset($t[98]) ? $t[98] : null;
            $loginName = isset($t[97]) ? $t[97] : null;

            $id = md5(strtoupper($lname) . strtoupper($fname) . strtoupper($midIni));
            $this->users[$id]['lname'] = isset($this->users[$id]['lname']) ? $this->users[$id]['lname'] : $lname;
            $this->users[$id]['fname'] = isset($this->users[$id]['fname']) ? $this->users[$id]['fname'] : $fname;
            $this->users[$id]['midIni'] = $midIni;
            $this->users[$id]['email'] = isset($this->users[$id]['email']) ? $this->users[$id]['email'] : $email;
            $this->users[$id]['phone'] = isset($this->users[$id]['phone']) ? $this->users[$id]['phone'] : $phone;
            $this->users[$id]['pager'] = $pager;
            $this->users[$id]['roomNum'] = $roomNum;
            $this->users[$id]['title'] = isset($this->users[$id]['title']) ? $this->users[$id]['title'] : $title;
            $this->users[$id]['service'] = isset($this->users[$id]['service']) ? $this->users[$id]['service'] : $service;
            $this->users[$id]['mailcode'] = $mailcode;
            $this->users[$id]['loginName'] = isset($this->users[$id]['loginName']) ? $this->users[$id]['loginName'] : $loginName;
            $this->users[$id]['source'] = 'vista';
            echo "Grabbing data for $lname, $fname\n";
            $count++;

            if ($count > 100)
            {
                $this->importData();
                $count = 0;
            }
        }
        $this->importData(); // import any remaining entries
    }

    /**
     * Imports data from \t and \n delimited file of format:
     * Name, Business Phone, Description, Modified, E-Mail Address,
     * User Logon Name
     * @param string $file
     *
     * @return mixed
     * @todo refactor to only one return statement, can this have only one return type?
     */
    public function importADData($file): mixed
    {
        $rawdata = file($file);
        // workaround for microsoft's crappy inconsistent software
        $rawheaders = trim(array_shift($rawdata));
        $headers = explode(',', $rawheaders);
        $idx = 0;
        $csvdeIdx = array();
        foreach ($headers as $header)
        {
            $csvdeIdx[$header] = $idx;
            $idx++;
        }

        if ($idx != 10)
        {
//            file_put_contents('Z:\phonebook\error.txt', 'Error: AD export');
            return 0;
        }

        $count = 0;

        foreach ($rawdata as $line)
        {
            $t = $this->splitWithEscape($line);
//            print_r($t);
//            $t = explode("\t", $line);
            array_walk($t, array($this, 'trimField2'));
            if (!is_array($t))
            {
                return 'invalid service';
            }

//            $tmp = explode(',', $t[0]);
            $lname = trim($t[$csvdeIdx['sn']]);
//            $tmp2 = explode(' ', trim($tmp[1]));
            $fname = trim($t[$csvdeIdx['givenName']]);
            $midIni = trim($t[$csvdeIdx['initials']]);
            $email = $t[$csvdeIdx['mail']] ? $t[$csvdeIdx['mail']] : null;
            $phone = $t[$csvdeIdx['telephoneNumber']] ? $t[$csvdeIdx['telephoneNumber']] : null;
            $pager = isset($t[94]) ? $t[94] : null;
            $roomNum = $t[$csvdeIdx['physicalDeliveryOfficeName']] ? $t[$csvdeIdx['physicalDeliveryOfficeName']] : null;
            $title = $t[$csvdeIdx['title']] ? $t[$csvdeIdx['title']] : null;
            $service = $t[$csvdeIdx['description']] ? $t[$csvdeIdx['description']] : null;
            $mailcode = isset($t[98]) ? $t[98] : null;
            $loginName = $t[$csvdeIdx['sAMAccountName']] ? $t[$csvdeIdx['sAMAccountName']] : null;

            $id = md5(strtoupper($lname) . strtoupper($fname) . strtoupper($midIni));
            $this->users[$id]['lname'] = $lname;
            $this->users[$id]['fname'] = $fname;
            $this->users[$id]['midIni'] = $midIni;
            $this->users[$id]['email'] = $email;
            $this->users[$id]['phone'] = $phone;
            $this->users[$id]['pager'] = $pager;
            $this->users[$id]['roomNum'] = $roomNum;
            $this->users[$id]['title'] = $title;
            $this->users[$id]['service'] = $service;
            $this->users[$id]['mailcode'] = $mailcode;
            $this->users[$id]['loginName'] = $loginName;
            $this->users[$id]['source'] = 'ad';
            echo "Grabbing data for $lname, $fname\n";
            $count++;

            if ($count > 100)
            {
                $this->importData();
                $count = 0;
            }
        }
        $this->importData(); // import any remaining entries
    }

    /**
     * Imports data from \t and \n delimited file of format:
     * Lname\t Fname Mid_Initial\t Email\t Phone\t Pager\t Room#\t Title\t Service\t MailCode\n
     * @param int $time
     * @param string $sql
     *
     * @return void
     * @todo should this return bool?
     */
    public function importData(): void
    {
        $time = $this->time;

        $sql = 'INSERT INTO Employee (Lname, Fname, Mid_Initial, Email, Phone, Pager, RoomNumber,
                            Title, Service, MailCode, PhoneticFname, PhoneticLname, LoginName, source, lastUpdated)
                            VALUES (:lname, :fname, :midIni, :email, :phone, :pager, :roomNum,
                            :title, :service, :mailcode, :phoneticFname, :phoneticLname, :loginName, :source, :lastUpdated)
                            ON DUPLICATE KEY UPDATE Lname=:lname, Fname=:fname, Mid_Initial=:midIni, Email=:email, Phone=:phone, Pager=:pager,
                                RoomNumber=:roomNum, Title=:title, Service=:service, lastUpdated=:lastUpdated';
        $pq = $this->db->prepare($sql);
        $count = 0;

        $userKeys = array_keys($this->users);

        foreach ($userKeys as $key)
        {
            $phoneticFname = metaphone($this->users[$key]['fname']);
            $phoneticLname = metaphone($this->users[$key]['lname']);

            $sql = 'SELECT * FROM Employee WHERE loginName = :loginName';
            $pq2 = $this->db->prepare($sql);
            $pq2->bindParam(':loginName', $this->users[$key]['loginName']);
            $pq2->execute();
            $res = $pq2->fetchAll();

            $pq->bindParam(':lname', $this->users[$key]['lname']);
            $pq->bindParam(':fname', $this->users[$key]['fname']);
            $pq->bindParam(':midIni', $this->users[$key]['midIni']);
            $pq->bindParam(':email', $this->users[$key]['email']);
            $pq->bindParam(':phone', $this->users[$key]['phone']);
            $pq->bindParam(':pager', $this->users[$key]['pager']);
            $pq->bindParam(':roomNum', $this->users[$key]['roomNum']);
            $pq->bindParam(':title', $this->users[$key]['title']);
            $pq->bindParam(':service', $this->users[$key]['service']);
            $pq->bindParam(':mailcode', $this->users[$key]['mailcode']);
            $pq->bindParam(':phoneticFname', $phoneticFname);
            $pq->bindParam(':phoneticLname', $phoneticLname);
            $pq->bindParam(':loginName', $this->users[$key]['loginName']);
            $pq->bindParam(':source', $this->users[$key]['source']);
            $pq->bindParam(':lastUpdated', $time);

            $pq->execute();
            echo "Inserting data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} : " . $pq->errorCode() . "\n";

            if ($pq->errorCode() != '00000')
            {
                print_r($pq->errorInfo());
            }
            $count++;

            unset($this->users[$key]);
        }

        echo 'Cleanup... ';
        // TODO: do some clean up
        echo "... Done.\n";

        echo "Total: $count";
    }

    /**
     * @param string $sql
     * @param \DB $pq
     *
     * @return void
     * @todo should this return bool?
     */
    public function deleteOld(): void
    {
        $sql = 'DELETE FROM Employee WHERE lastUpdated < :time';
        $pq = $this->db->prepare($sql);
        $pq->bindParam(':time', $this->time);
        $pq->execute();
    }

    /**
     * @param string $lname
     * @param string $fname
     * @param string $midIni
     * @param string $email
     * @param string $phone
     * @param string $pager
     * @param string $roomNum
     * @param string $title
     * @param string $service
     * @param string $mailcode
     * @param string $loginName
     *
     * @return bool
     * @todo refactor so all code paths return a value
     */
    public function importExtra($lname, $fname, $midIni, $email, $phone, $pager, $roomNum, $title, $service, $mailcode, $loginName): bool
    {
        $sql = 'SELECT * FROM Employee WHERE loginName = :loginName';
        $pq2 = $this->db->prepare($sql);
        $pq2->bindParam(':loginName', $loginName);
        $pq2->execute();
        $res = $pq2->fetchAll();

        if (count($res) > 0)
        {
            echo "Ignoring data for {$lname}, {$fname} : Already in database. \n";

            return true;
        }

        $sql = 'INSERT INTO Employee (Lname, Fname, Mid_Initial, Email, Phone, Pager, RoomNumber,
                            Title, Service, MailCode, PhoneticFname, PhoneticLname, LoginName, source, lastUpdated)
                            VALUES (:lname, :fname, :midIni, :email, :phone, :pager, :roomNum,
                            :title, :service, :mailcode, :phoneticFname, :phoneticLname, :loginName, :source, :lastUpdated)';
        $pq = $this->db->prepare($sql);
        $count = 0;

        $phoneticFname = metaphone($fname);
        $phoneticLname = metaphone($lname);
        $tmp = 'extra';
        $pq->bindParam(':lname', $lname);
        $pq->bindParam(':fname', $fname);
        $pq->bindParam(':midIni', $midIni);
        $pq->bindParam(':email', $email);
        $pq->bindParam(':phone', $phone);
        $pq->bindParam(':pager', $pager);
        $pq->bindParam(':roomNum', $roomNum);
        $pq->bindParam(':title', $title);
        $pq->bindParam(':service', $service);
        $pq->bindParam(':mailcode', $mailcode);
        $pq->bindParam(':phoneticFname', $phoneticFname);
        $pq->bindParam(':phoneticLname', $phoneticLname);
        $pq->bindParam(':loginName', $loginName);
        $pq->bindParam(':source', $tmp);
        $pq->bindParam(':lastUpdated', $this->time);

        $pq->execute();
        //echo "Inserting data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} : " . $pq->errorCode() . "\n";
        if ($pq->errorCode() != '00000')
        {
            print_r($pq->errorInfo());
        }

        echo "Inserted Extra: $lname, $fname";
    }

    /**
     * Updates phonetic cache
     * @param string $sql
     * @param array $res
     *
     * @return void
     */
    public function updatePhoneticNames(): void
    {
        $sql = "SELECT * FROM {$this->tableName}";

        $res = $this->db->prepared_query($sql, array())->fetchAll(\PDO::FETCH_ASSOC);
        echo 'Generating phonetic cache...';

        foreach ($res as $emp)
        {
            $pFirst = metaphone($emp['Fname']);
            $pLast = metaphone($emp['Lname']);
            $vars = array("first" => $pFirst, "empUID" => $emp['EmpID']);
            $sql = "UPDATE {$this->tableName} SET PhoneticFname = ':first' WHERE EmpID = :empUID";
            $query = $this->db->prepared_query($sql, $vars);
            // $query->execute();

            $vars2 = array("last" => $pLast, "empUID" => $emp['EmpID']);
            $sql = "UPDATE {$this->tableName} SET PhoneticLname = ':last' WHERE EmpID = :empUID";
            $query2 = $this->db->prepared_query($sql, $vars2);
            // $query->execute();
        }
    }

    // Log errors from the database
    private function logError($error)
    {
        $this->log[] = $error;
    }

    // Translates the * wildcard to SQL % wildcard
    private function parseWildcard($query)
    {
        return str_replace('*', '%', $query . '*');
    }

    // Trims input
    private function trimField(&$value, &$key)
    {
        $value = trim($value);
        $value = trim($value, '.');
    }

    // Trims input
    private function trimField2(&$value, &$key)
    {
        $value = trim($value);
        $value = trim($value, '.');
    }

    private function ucwordss($str)
    {
        $lowerCase = array('OF');
        $out = '';
        foreach (explode(' ', $str) as $word)
        {
            if (in_array($word, $lowerCase))
            {
                $out .= strtolower($word) . ' ';
            }
            elseif (strlen($word) > 4 || metaphone($word) != $word)
            {
                $out .= strtoupper($word[0]) . substr(strtolower($word), 1) . ' ';
            }
            else
            {
                $out .= $word . ' ';
            }
        }

        return rtrim($out);
    }

    // Clean up all wildcards
    private function cleanWildcards($input)
    {
        $input = preg_replace('/\*+/i', '*', $input);
        $input = preg_replace('/(\*\s\*)+/i', '', $input);

        return $input;
    }

    // workaround for excel
    // author: tajhlande at gmail dot com
    private function splitWithEscape($str, $delimiterChar = ',', $escapeChar = '"')
    {
        $len = strlen($str);
        $tokens = array();
        $i = 0;
        $inEscapeSeq = false;
        $currToken = '';
        while ($i < $len)
        {
            $c = substr($str, $i, 1);
            if ($inEscapeSeq)
            {
                if ($c == $escapeChar)
                {
                    // lookahead to see if next character is also an escape char
                    if ($i == ($len - 1))
                    {
                        // c is last char, so must be end of escape sequence
                        $inEscapeSeq = false;
                    }
                    elseif (substr($str, $i + 1, 1) == $escapeChar)
                    {
                        // append literal escape char
                        $currToken .= $escapeChar;
                        $i++;
                    }
                    else
                    {
                        // end of escape sequence
                        $inEscapeSeq = false;
                    }
                }
                else
                {
                    $currToken .= $c;
                }
            }
            else
            {
                if ($c == $delimiterChar)
                {
                    // end of token, flush it
                    array_push($tokens, $currToken);
                    $currToken = '';
                }
                elseif ($c == $escapeChar)
                {
                    // begin escape sequence
                    $inEscapeSeq = true;
                }
                else
                {
                    $currToken .= $c;
                }
            }
            $i++;
        }
        // flush the last token
        array_push($tokens, $currToken);

        return $tokens;
    }
}
