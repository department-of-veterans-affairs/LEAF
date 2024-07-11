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
namespace Leaf;

class VAMCActiveDirectory
{
    private $db;                        // The database object

    private $users = array();

    // Connect to the database
    public function __construct($national_db)
    {
        $this->db = $national_db;
    }

    // Imports data from \t and \n delimited file of format:
    // Name	Business Phone	Description	Modified	E-Mail Address	User Logon Name
    public function importADData($file)
    {
        $data = $this->getData($file);
        $rawdata = explode("\r\n", $data[0]['data']);
        $rawheaders = trim(array_shift($rawdata));
        $headers = explode(',', $rawheaders);
        $idx = 0;
        $csvdeIdx = array();

        foreach ($headers as $header) {
            $csvdeIdx[$header] = $idx;
            $idx++;
        }

        $count = 0;

        foreach ($rawdata as $line) {
            $t = $this->splitWithEscape($line);
            array_walk($t, array($this, 'trimField2'));

            if (!is_array($t)) {
                return 'invalid service';
            }

            $lname = trim($t[$csvdeIdx['sn']]);
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
            $objectGUID = null;
            $mobile = isset($t[$csvdeIdx['mobile']]) ? $t[$csvdeIdx['mobile']] : null;
            $domain = $t[$csvdeIdx['DN']] ? $t[$csvdeIdx['DN']] : null;
            $domain = $this->parseVAdomain($domain);

            $id = md5(strtoupper($lname) . strtoupper($fname) . strtoupper($midIni));

            if ($lname != '') {
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
                $this->users[$id]['objectGUID'] = $objectGUID;
                $this->users[$id]['mobile'] = $mobile;
                $this->users[$id]['domain'] = $domain;
                $this->users[$id]['source'] = 'ad';
                echo "Grabbing data for $lname, $fname\n";
                $count++;
            } else {
                echo "{$loginName} probably not a user, skipping.\n";
            }

            if ($count > 100) {
                $this->importData();
                $count = 0;
            }
        }

        $this->importData(); // import any remaining entries
    }

    // Imports data from \t and \n delimited file of format:
    // Lname\t Fname Mid_Initial\t Email\t Phone\t Pager\t Room#\t Title\t Service\t MailCode\n
    public function importData()
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
                echo "Updating data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} \n";

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 6,
                            ':data' => $this->users[$key]['email']);
                $sql = "INSERT INTO `employee_data` (`empUID`, `indicatorID`, `data`, `author`)
                        VALUES (:empUID, :indicatorID, :data, 'system')
                        ON DUPLICATE KEY UPDATE `data` = :data";

                $pq3 = $this->db->prepared_query($sql, $vars);

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 5,
                            ':data' => $this->fixIfHex($this->users[$key]['phone']));

                $pq3 = $this->db->prepared_query($sql, $vars);

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 8,
                            ':data' => $this->fixIfHex($this->users[$key]['roomNum']));

                $pq3 = $this->db->prepared_query($sql, $vars);

                $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 23,
                            ':data' => $this->fixIfHex($this->users[$key]['title']));

                $pq3 = $this->db->prepared_query($sql, $vars);

                // don't store mobile # if it's the same as the primary phone #
                if ($this->users[$key]['phone'] != $this->users[$key]['mobile']) {
                    $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 16,
                            ':data' => $this->fixIfHex($this->users[$key]['mobile']));

                    $pq3 = $this->db->prepared_query($sql, $vars);
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

                $pq3 = $this->db->prepared_query($sql, $vars);
            } else {
                $vars = array(':loginName', $this->users[$key]['loginName'],
                            ':lname', $this->users[$key]['lname'],
                            ':fname', $this->users[$key]['fname'],
                            ':midIni', $this->users[$key]['midIni'],
                            ':phoneticFname', $phoneticFname,
                            ':phoneticLname', $phoneticLname,
                            ':domain', $this->users[$key]['domain'],
                            ':lastUpdated', $time);

                $pq = $this->db->prepared_query($sql1, $vars);

                echo "Inserting data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} : " . $pq->errorCode() . "\n";

                $lastEmpUID = $this->db->lastInsertId();

                if ($pq->errorCode() != '00000') {
                    print_r($pq->errorInfo());
                }

                // prioritize adding email to DB
                $sql = "INSERT INTO employee_data (empUID, indicatorID, data, author)
                            VALUES (:empUID, :indicatorID, :data, 'system')
                            ON DUPLICATE KEY UPDATE data=:data";

                $vars = array(':empUID', $lastEmpUID,
                            ':indicatorID', 6,
                            ':data', $this->users[$key]['email']);
                $pq3 = $this->db->prepared_query($sql, $vars);
                $count++;
            }

            unset($this->users[$key]);
        }

        echo 'Cleanup... ';
        // TODO: do some clean up
        echo "... Done.\n";

        echo "Total: $count";
    }

    private function getData(string $file): array
    {
        $vars = array(':file' => $file);
        $sql = 'SELECT `data`
                FROM `cache`
                WHERE `cacheID` = :file';

        $data = $this->db->prepared_query($sql, $vars);

        //$this->removeData($file);

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
    private function splitWithEscape($str, $delimiterChar = ',', $escapeChar = '"')
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

    private function parseVAdomain($adPath)
    {
        $dc = '';
        $dcSrc = explode(',', $adPath);

        foreach ($dcSrc as $adElement) {
            if (strpos($adElement, 'DC=') !== false) {
                $dc .= substr($adElement, 3) . '.';
            }
        }

        $dc = trim($dc, '.');

        switch ($dc) {
            case 'v01.med.va.gov':
                return 'VHA01';
            case 'v02.med.va.gov':
                return 'VHA02';
            case 'v03.med.va.gov':
                return 'VHA03';
            case 'v04.med.va.gov':
                return 'VHA04';
            case 'v05.med.va.gov':
                return 'VHA05';
            case 'v06.med.va.gov':
                return 'VHA06';
            case 'v07.med.va.gov':
                return 'VHA07';
            case 'v08.med.va.gov':
                return 'VHA08';
            case 'v09.med.va.gov':
                return 'VHA09';
            case 'v10.med.va.gov':
                return 'VHA10';
            case 'v11.med.va.gov':
                return 'VHA11';
            case 'v12.med.va.gov':
                return 'VHA12';
            case 'v13.med.va.gov':
                return 'VHA13';
            case 'v14.med.va.gov':
                return 'VHA14';
            case 'v15.med.va.gov':
                return 'VHA15';
            case 'v16.med.va.gov':
                return 'VHA16';
            case 'v17.med.va.gov':
                return 'VHA17';
            case 'v18.med.va.gov':
                return 'VHA18';
            case 'v19.med.va.gov':
                return 'VHA19';
            case 'v20.med.va.gov':
                return 'VHA20';
            case 'v21.med.va.gov':
                return 'VHA21';
            case 'v22.med.va.gov':
                return 'VHA22';
            case 'v23.med.va.gov':
                return 'VHA23';
            default:
                return $dc;
        }
    }

    //tests stringToFix for format X'...', if it matches, it's a hex value, is decoded and returned
    private function fixIfHex($stringToFix)
    {
        if(substr( $stringToFix, 0, 2 ) === "X'") {
            $stringToFix = ltrim($stringToFix, "X'");
            $stringToFix = rtrim($stringToFix, "'");
            $stringToFix = hex2bin($stringToFix);
        }

        return $stringToFix;
    }
}
