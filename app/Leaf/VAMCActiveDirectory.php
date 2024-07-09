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
    public function importADData($data)
    {
        $rawdata = explode("\r\n", $data);
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
        $sql = 'INSERT INTO employee (userName, lastName, firstName, middleName, phoneticFirstName, phoneticLastName, domain, lastUpdated, new_empUUID)
                    VALUES (:loginName, :lname, :fname, :midIni, :phoneticFname, :phoneticLname, :domain, :lastUpdated, uuid())';

        $pq = $this->db->prepare($sql);
        $count = 0;

        $userKeys = array_keys($this->users);

        foreach ($userKeys as $key)
        {
            $phoneticFname = metaphone($this->users[$key]['fname']);
            $phoneticLname = metaphone($this->users[$key]['lname']);

            $sql = 'SELECT SQL_NO_CACHE * FROM employee WHERE username = :loginName';
            $pq2 = $this->db->prepare($sql);
            $pq2->bindParam(':loginName', $this->users[$key]['loginName']);
            $pq2->execute();
            $res = $pq2->fetchAll();

            if (count($res) > 0) {
                echo "Updating data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} \n";

                $sql = "INSERT INTO employee_data (empUID, indicatorID, data, author)
                            VALUES (:empUID, :indicatorID, :data, 'system')
                            ON DUPLICATE KEY UPDATE data=:data";

                $pq3 = $this->db->prepare($sql);
                $pq3->bindParam(':empUID', $res[0]['empUID']);
                $id = 6;
                $pq3->bindParam(':indicatorID', $id);
                $pq3->bindParam(':data', $this->users[$key]['email']);
                $pq3->execute();

                $pq3 = $this->db->prepare($sql);
                $pq3->bindParam(':empUID', $res[0]['empUID']);
                $id = 5;
                $pq3->bindParam(':indicatorID', $id);
                $pq3->bindParam(':data', $this->fixIfHex($this->users[$key]['phone']));
                $pq3->execute();

                $pq3 = $this->db->prepare($sql);
                $pq3->bindParam(':empUID', $res[0]['empUID']);
                $id = 8;
                $pq3->bindParam(':indicatorID', $id);
                $pq3->bindParam(':data', $this->fixIfHex($this->users[$key]['roomNum']));
                $pq3->execute();

                $pq3 = $this->db->prepare($sql);
                $pq3->bindParam(':empUID', $res[0]['empUID']);
                $id = 23;
                $pq3->bindParam(':indicatorID', $id);
                $pq3->bindParam(':data', $this->fixIfHex($this->users[$key]['title']));
                $pq3->execute();

                // don't store mobile # if it's the same as the primary phone #
                if ($this->users[$key]['phone'] != $this->users[$key]['mobile']) {
                    $pq3 = $this->db->prepare($sql);
                    $pq3->bindParam(':empUID', $res[0]['empUID']);
                    $id = 16;
                    $pq3->bindParam(':indicatorID', $id);
                    $pq3->bindParam(':data', $this->fixIfHex($this->users[$key]['mobile']));
                    $pq3->execute();
                }

                $sql = 'UPDATE employee SET lastName=:lname,
                                firstName=:fname,
                                middleName=:midIni,
                                phoneticFirstName=:phoneticFname,
                                phoneticLastName=:phoneticLname,
                				domain=:domain,
                                lastUpdated=:lastUpdated,
                				deleted = 0
                            WHERE username=:userName';

                $pq3 = $this->db->prepare($sql);
                $pq3->bindParam(':userName', $this->users[$key]['loginName']);
                $pq3->bindParam(':lname', $this->users[$key]['lname']);
                $pq3->bindParam(':fname', $this->users[$key]['fname']);
                $pq3->bindParam(':midIni', $this->users[$key]['midIni']);
                $pq3->bindParam(':phoneticFname', $phoneticFname);
                $pq3->bindParam(':phoneticLname', $phoneticLname);
                $pq3->bindParam(':domain', $this->users[$key]['domain']);
                $pq3->bindParam(':lastUpdated', $time);
                $pq3->execute();
            } else {
                $pq->bindParam(':loginName', $this->users[$key]['loginName']);
                $pq->bindParam(':lname', $this->users[$key]['lname']);
                $pq->bindParam(':fname', $this->users[$key]['fname']);
                $pq->bindParam(':midIni', $this->users[$key]['midIni']);
                $pq->bindParam(':phoneticFname', $phoneticFname);
                $pq->bindParam(':phoneticLname', $phoneticLname);
                $pq->bindParam(':domain', $this->users[$key]['domain']);
                $pq->bindParam(':lastUpdated', $time);

                $pq->execute();
                echo "Inserting data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} : " . $pq->errorCode() . "\n";

                $lastEmpUID = $this->db->lastInsertId();

                if ($pq->errorCode() != '00000') {
                    print_r($pq->errorInfo());
                }

                // prioritize adding email to DB
                $sql = "INSERT INTO employee_data (empUID, indicatorID, data, author)
                            VALUES (:empUID, :indicatorID, :data, 'system')
                            ON DUPLICATE KEY UPDATE data=:data";

                $pq3 = $this->db->prepare($sql);
                $pq3->bindParam(':empUID', $lastEmpUID);
                $id = 6;
                $pq3->bindParam(':indicatorID', $id);
                $pq3->bindParam(':data', $this->users[$key]['email']);
                $pq3->execute();
                $count++;
            }

            unset($this->users[$key]);
        }

        echo 'Cleanup... ';
        // TODO: do some clean up
        echo "... Done.\n";

        echo "Total: $count";
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
