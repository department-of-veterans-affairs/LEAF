<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    VAMC_directory_maintenance
    Date: June 13, 2007

    + Imports data into an employee contact information database
    + Multiple data sources
    + Buffered inserts for low memory usage
*/
namespace App\Leaf;

class VAMCActiveDirectory
{
    private $db;                        // The database object

    private $users = array();

    private $headers = array('sn' => 'lname',
                'givenName' => 'fname',
                'initials' => 'midIni',
                'mail' => 'email',
                'telephoneNumber' => 'phone',
                94 => 'pager',
                'physicalDeliveryOfficeName' => 'roomNum',
                'title' => 'title',
                'description' => 'service',
                98 => 'mailcode',
                'sAMAccountName' => 'loginName',
                'mobile' => 'mobile',
                'DN' => 'domain',
                'objectGUID' => 'guid');

    // Connect to the database
    public function __construct($national_db)
    {
        $this->db = $national_db;
    }

    // Imports data from \t and \n delimited file of format:
    // Name	Business Phone	Description	Modified	E-Mail Address	User Logon Name
    public function importADData(string $file): string
    {
        $data = $this->getData($file);
        $rawdata = explode("\r\n", $data[0]['data']);
        $rawheaders = trim(array_shift($rawdata));
        $rawheaders = explode(',', $rawheaders);

        foreach ($rawdata as $key => $line) {
            $t = $this->splitWithEscape($line);
            array_walk($t, array($this, 'trimField2'));

            if (!is_array($t)) {
                return 'invalid service';
            }

            foreach ($t as $t_key => $val) {
                $head_check = $rawheaders[$t_key];

                if (!isset($this->headers[$head_check])) {
                    return 'invalid header';
                }

                $write_data[$key][$this->headers[$head_check]] = $val;
            }
        }

        $count = 0;

        foreach ($write_data as $employee) {
            if (
                isset($employee['lname'])
                && $employee['lname'] != ''
                && isset($employee['loginName'])
                && $employee['loginName'] != ''
                && !is_numeric($employee['loginName'])
                && !str_contains($employee['loginName'], '.')
            ) {
                $id = md5(strtoupper($employee['lname']) . strtoupper($employee['fname']) . strtoupper($employee['midIni']));

                $this->users[$id]['lname'] = $employee['lname'];
                $this->users[$id]['fname'] = $employee['fname'];
                $this->users[$id]['midIni'] = $employee['midIni'];
                $this->users[$id]['email'] = isset($employee['email']) ? $employee['email'] : null;
                $this->users[$id]['phone'] = $employee['phone'];
                $this->users[$id]['pager'] = isset($employee['pager']) ? $employee['pager'] : null;
                $this->users[$id]['roomNum'] = $employee['roomNum'];
                $this->users[$id]['title'] = $employee['title'];
                $this->users[$id]['service'] = $employee['service'];
                $this->users[$id]['mailcode'] = isset($employee['mailcode']) ? $employee['mailcode'] : null;
                $this->users[$id]['loginName'] = $employee['loginName'];
                $this->users[$id]['objectGUID'] = null;
                $this->users[$id]['mobile'] = $employee['mobile'];
                $this->users[$id]['domain'] = $employee['domain'];
                $this->users[$id]['source'] = 'ad';
                //echo "Grabbing data for $employee['lname'], $employee['fname']\n";
                $count++;
            } else {
                $ln = isset($employee['loginName']) ? $employee['loginName'] : 'no login name';
                $lan = isset($employee['lname']) ? $employee['lname'] : 'no last name';
                $message = "{$ln} - {$lan} probably not a user, skipping.\n";
                error_log($message, 3, '/var/www/php-logs/ad_processing.log');
            }

            if ($count > 100) {
                $this->importData();
                $count = 0;
            }
        }

        // import any remaining entries
        $this->importData();
    }

    public function disableNationalOrgchartEmployees(): void
    {
        // get all userNames that should be disabled
        $disableUsersList = $this->getUserNamesToBeDisabled();

        // Disable users not in this array
        $this->preventRecycledUserName($disableUsersList);
    }

    // Imports data from \t and \n delimited file of format:
    // Lname\t Fname Mid_Initial\t Email\t Phone\t Pager\t Room#\t Title\t Service\t MailCode\n
    public function importData(): void
    {
        $time = time();
        $sql1 = 'INSERT INTO employee (userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName, domain, lastUpdated, new_empUUID)
                    VALUES (:loginName, :lname, :fname, :midIni, :phoneticFname, :phoneticLname, :domain, :lastUpdated, uuid())';

        $count = 0;

        $userKeys = array_keys($this->users);

        foreach ($userKeys as $key) {
            $phoneticFname = metaphone($this->users[$key]['fname']);
            $phoneticLname = metaphone($this->users[$key]['lname']);

            $vars = array(':loginName' => $this->users[$key]['loginName']);
            $sql = 'SELECT SQL_NO_CACHE *
                    FROM employee
                    WHERE username = :loginName';

            $res = $this->db->prepared_query($sql, $vars);

            if (count($res) > 0) {
                //echo "Updating data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} \n";

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 6,
                            ':data' => $this->users[$key]['email']);
                $sql = "INSERT INTO `employee_data` (`empUID`, `indicatorID`, `data`, `author`)
                        VALUES (:empUID, :indicatorID, :data, 'system')
                        ON DUPLICATE KEY UPDATE `data` = :data";

                $this->db->prepared_query($sql, $vars);

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 5,
                            ':data' => $this->fixIfHex($this->users[$key]['phone']));

                $this->db->prepared_query($sql, $vars);

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 8,
                            ':data' => $this->fixIfHex($this->users[$key]['roomNum']));

                $this->db->prepared_query($sql, $vars);

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 23,
                            ':data' => $this->fixIfHex($this->users[$key]['title']));

                $this->db->prepared_query($sql, $vars);

                // don't store mobile # if it's the same as the primary phone #
                if ($this->users[$key]['phone'] != $this->users[$key]['mobile']) {
                    $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 16,
                            ':data' => $this->fixIfHex($this->users[$key]['mobile']));

                    $this->db->prepared_query($sql, $vars);
                }

                $vars = array(':lname' => $this->users[$key]['lname'],
                            ':fname' => $this->users[$key]['fname'],
                            ':midIni' => $this->users[$key]['midIni'],
                            ':phoneticFname' => $phoneticFname,
                            ':phoneticLname' => $phoneticLname,
                            ':domain' => $this->users[$key]['domain'],
                            ':lastUpdated' => $time,
                            ':userName' => $this->users[$key]['loginName']);
                $sql = 'UPDATE employee
                        SET lastName = :lname,
                            firstName = :fname,
                            middleName = :midIni,
                            phoneticFirstName = :phoneticFname,
                            phoneticLastName = :phoneticLname,
                			domain = :domain,
                            lastUpdated = :lastUpdated,
                			deleted = 0
                        WHERE username = :userName';

                $this->db->prepared_query($sql, $vars);
            } else {
                $vars = array(':loginName', $this->users[$key]['loginName'],
                            ':lname', $this->users[$key]['lname'],
                            ':fname', $this->users[$key]['fname'],
                            ':midIni', $this->users[$key]['midIni'],
                            ':phoneticFname', $phoneticFname,
                            ':phoneticLname', $phoneticLname,
                            ':domain', $this->users[$key]['domain'],
                            ':lastUpdated', $time);

                $this->db->prepared_query($sql1, $vars);

                //echo "Inserting data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} : " . $pq->errorCode() . "\n";

                $lastEmpUID = $this->db->getLastInsertId();

                // prioritize adding email to DB
                $sql = "INSERT INTO employee_data (empUID, indicatorID, data, author)
                            VALUES (:empUID, :indicatorID, :data, 'system')
                            ON DUPLICATE KEY UPDATE data=:data";

                $vars = array(':empUID', $lastEmpUID,
                            ':indicatorID', 6,
                            ':data', $this->users[$key]['email']);
                $this->db->prepared_query($sql, $vars);
                $count++;
            }

            unset($this->users[$key]);
        }

        echo 'Cleanup... ';
        // TODO: do some clean up
        echo "... Done.\n";

        echo "Total: $count";
    }

    private function getUserNamesToBeDisabled(): array
    {
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `deleted` = 0
                AND `lastUpdated` < (UNIX_TIMESTAMP(NOW()) - 108000)';

        $return_value = $this->db->prepared_query($sql, array());

        return $return_value;
    }

    private function preventRecycledUserName(array $userNames): void
    {
        $deleteTime = time();

        $vars = array(':deleteTime' => $deleteTime);
        $sql = 'UPDATE `employee`
                SET `deleted` = :deleteTime,
                    `userName` = concat("disabled_", `deleted`, "_",  `userName`)
                WHERE `userName` = :userName;

                UPDATE `employee_data`
                SET `author` = concat("disabled_", :deleteTime, "_",  :userName)
                WHERE `author` = :userName;

                UPDATE `employee_data_history`
                SET `author` = concat("disabled_", :deleteTime, "_",  :userName)
                WHERE `author` = :userName;

                UPDATE `group_data`
                SET `author` = concat("disabled_", :deleteTime, "_",  :userName)
                WHERE `author` = :userName;

                UPDATE `group_data_history`
                SET `author` = concat("disabled_", :deleteTime, "_",  :userName)
                WHERE `author` = :userName;

                UPDATE `position_data`
                SET `author` = concat("disabled_", :deleteTime, "_",  :userName)
                WHERE `author` = :userName;

                UPDATE `position_data_history`
                SET `author` = concat("disabled_", :deleteTime, "_",  :userName)
                WHERE `author` = :userName;

                UPDATE `relation_employee_backup`
                SET `approverUserName` = concat("disabled_", :deleteTime, "_",  :userName)
                WHERE `approverUserName` = :userName;';

        foreach ($userNames as $user) {
            $vars[':userName'] = $user['userName'];

            $this->db->prepared_query($sql, $vars);
        }
    }

    private function getData(string $file): array
    {
        $vars = array(':file' => $file);
        $sql = 'SELECT `data`
                FROM `cache`
                WHERE `cacheID` = :file';

        $data = $this->db->prepared_query($sql, $vars);

        $this->removeData($file);

        return $data;
    }

    private function removeData(string $file): void
    {
        $vars = array(':file' => $file);
        $sql = 'DELETE
                FROM `cache`
                WHERE `cacheID` = :file';

        $this->db->prepared_query($sql, $vars);
    }

    private function trimField2(string &$value, string $key): void
    {
        $value = trim($value);
        $value = trim($value, '.');
    }

    // workaround for excel
    // author: tajhlande at gmail dot com
    private function splitWithEscape(string $str, string $delimiterChar = ',', string $escapeChar = '"'): array
    {
        $len = strlen($str);
        $tokens = array();
        $i = 0;
        $inEscapeSeq = false;
        $currToken = '';

        while ($i < $len) {
            $c = substr($str, $i, 1);

            if ($inEscapeSeq) {
                if ($c == $escapeChar) {
                    // lookahead to see if next character is also an escape char
                    if ($i == ($len - 1)) {
                        // c is last char, so must be end of escape sequence
                        $inEscapeSeq = false;
                    } elseif (substr($str, $i + 1, 1) == $escapeChar) {
                        // append literal escape char
                        $currToken .= $escapeChar;
                        $i++;
                    } else {
                        // end of escape sequence
                        $inEscapeSeq = false;
                    }
                } else {
                    $currToken .= $c;
                }
            } else {
                if ($c == $delimiterChar) {
                    // end of token, flush it
                    array_push($tokens, $currToken);
                    $currToken = '';
                } elseif ($c == $escapeChar) {
                    // begin escape sequence
                    $inEscapeSeq = true;
                } else {
                    $currToken .= $c;
                }
            }

            $i++;
        }

        // flush the last token
        array_push($tokens, $currToken);

        return $tokens;
    }

    //tests stringToFix for format X'...', if it matches, it's a hex value, is decoded and returned
    private function fixIfHex(string $stringToFix): string
    {
        if (substr( $stringToFix, 0, 2 ) === "X'") {
            $stringToFix = ltrim($stringToFix, "X'");
            $stringToFix = rtrim($stringToFix, "'");
            $stringToFix = hex2bin($stringToFix);
        }

        return $stringToFix;
    }
}