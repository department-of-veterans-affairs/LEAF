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

    private $disable_time;

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
        $this->disable_time = time();
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
	    ) {
		    if(empty($employee['midIni'])){
			    $employee['midIni'] = '';
		    }

            // there is incomplete data in ad in some cases.
		    if(empty($employee['fname'])){
			    $employee['fname'] = '';
		    }
                $id = md5(strtoupper($employee['lname']) . strtoupper($employee['fname']) . strtoupper($employee['midIni']));

                $this->users[$id]['lname'] = $employee['lname'];
                $this->users[$id]['fname'] = $employee['fname'];
                $this->users[$id]['midIni'] = $employee['midIni'];
                $this->users[$id]['email'] = isset($employee['email']) ? $employee['email'] : '';
                $this->users[$id]['phone'] = isset($employee['phone']) ? $employee['phone'] : '';
                $this->users[$id]['pager'] = isset($employee['pager']) ? $employee['pager'] : '';
                $this->users[$id]['roomNum'] = isset($employee['roomNum']) ? $employee['roomNum'] : '';
                $this->users[$id]['title'] = isset($employee['title']) ? $employee['title'] : '';
                $this->users[$id]['service'] = isset($employee['service']) ? $employee['service'] : '';
                $this->users[$id]['mailcode'] = isset($employee['mailcode']) ? $employee['mailcode'] : '';
                $this->users[$id]['loginName'] = $employee['loginName'];
                $this->users[$id]['objectGUID'] = null;
                $this->users[$id]['mobile'] = isset($employee['mobile']) ? $employee['mobile'] : '';
                $this->users[$id]['domain'] = $this->parseVAdomain($employee['domain']);
                $this->users[$id]['source'] = 'ad';
                //echo "Grabbing data for $employee['lname'], $employee['fname']\n";
                $count++;
            } else if (stristr($employee['domain'],'Service Accounts')) {
                $id = md5('ACCOUNT' . 'SERVICE' . $count);

                $this->users[$id]['lname'] = 'Account';
                $this->users[$id]['fname'] = 'Service';
                $this->users[$id]['midIni'] = '';
                $this->users[$id]['email'] = isset($employee['email']) ? $employee['email'] : '';
                $this->users[$id]['phone'] = isset($employee['phone']) ? $employee['phone'] : '';
                $this->users[$id]['pager'] = isset($employee['pager']) ? $employee['pager'] : '';
                $this->users[$id]['roomNum'] = isset($employee['roomNum']) ? $employee['roomNum'] : '';
                $this->users[$id]['title'] = isset($employee['title']) ? $employee['title'] : '';
                $this->users[$id]['service'] = isset($employee['service']) ? $employee['service'] : '';
                $this->users[$id]['mailcode'] = isset($employee['mailcode']) ? $employee['mailcode'] : '';
                $this->users[$id]['loginName'] = $employee['loginName'];
                $this->users[$id]['objectGUID'] = null;
                $this->users[$id]['mobile'] = isset($employee['mobile']) ? $employee['mobile'] : '';
                $this->users[$id]['domain'] = $this->parseVAdomain($employee['domain']);
                $this->users[$id]['source'] = 'ad';
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

        return '';
    }

    /**
     * get a list of employees to disable if not supplied in the parameter list
     * then disable them in the national orgchart
     *
     * @param array|null $disabledUsers
     *
     * @return void
     *
     */
    public function disableNationalOrgchartEmployees(?array $disabledUsers = null): void
    {
        // make sure that an update occurred within the last 2 hours
        if ($this->checkForUpdates()) {
            // get all userNames that should be disabled
            if ($disabledUsers === null) {
                $disableUsersList = $this->getUserNamesToBeDisabled();
            } else {
                $disableUsersList = $disabledUsers;
            }

            // Disable users not in this array
            $this->preventRecycledUserName($disableUsersList);
        }

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
                if(!empty($this->users[$key]['phone'])){
                    $vars = array(':empUID' => $res[0]['empUID'],
                                ':indicatorID' => 5,
                                ':data' => $this->fixIfHex($this->users[$key]['phone']));


                    $this->db->prepared_query($sql, $vars);
                }

                if(!empty($this->users[$key]['roomNum'])){
                    $vars = array(':empUID' => $res[0]['empUID'],
                                ':indicatorID' => 8,
                                ':data' => $this->fixIfHex($this->users[$key]['roomNum']));

                    $this->db->prepared_query($sql, $vars);
                }

                if(!empty($this->users[$key]['title'])){
                    $vars = array(':empUID' => $res[0]['empUID'],
                                ':indicatorID' => 23,
                                ':data' => $this->fixIfHex($this->users[$key]['title']));

                    $this->db->prepared_query($sql, $vars);
                }

                // don't store mobile # if it's the same as the primary phone #
                if (!empty($this->users[$key]['mobile']) && $this->users[$key]['phone'] != $this->users[$key]['mobile']) {
                    $vars = array(':empUID' => $res[0]['empUID'],
                            ':indicatorID' => 16,
                            ':data' => $this->fixIfHex($this->users[$key]['mobile']));

                    $this->db->prepared_query($sql, $vars);
                    

                } else {
                    // need to check and see if mobile exists in the db now, if it does
                    // need to remove it or change it to a blank string
                    $vars[':indicatorID'] = 16;
                    unset($vars[':data']);

                    $mobile_sql = 'SELECT *
                                   FROM `employee_data`
                                   WHERE `indicatorID` = :indicatorID
                                   AND `empUID` = :empUID';

                    $res = $this->db->prepared_query($mobile_sql, $vars);

                    if (!empty($res)) {
                        $vars[':data'] = '';

                        $this->db->prepared_query($sql, $vars);
                    }
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
                $vars = array(':loginName' => $this->users[$key]['loginName'],
                            ':lname' => $this->users[$key]['lname'],
                            ':fname' => $this->users[$key]['fname'],
                            ':midIni' => $this->users[$key]['midIni'],
                            ':phoneticFname' => $phoneticFname,
                            ':phoneticLname' => $phoneticLname,
			                ':domain' => $this->users[$key]['domain'],
                            ':lastUpdated' => $time);

                $this->db->prepared_query($sql1, $vars);

                //echo "Inserting data for {$this->users[$key]['lname']}, {$this->users[$key]['fname']} : "  . "\n";

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
    }

    private function checkForUpdates(): bool
    {
        // because this runs right after the update I feel confident we can do a 2 hour
        // check, on staging the update only takes 30-40 minutes.
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `deleted` = 0
                AND `lastUpdated` > (UNIX_TIMESTAMP(NOW()) - 7200)';

        $result = $this->db->prepared_query($sql, array());

        // checking to make sure more than just 1 or 2 were updated
        // want to do it this way because someone could have updated
        // someone manually causing this check to be a false positive.
        // But it's pretty safe to say that if 200,000 got updated that
        // the update script worked and we are good to disable anyone else.
        $minimum_count = strpos(LEAF_NEXUS_URL, 'host.docker.internal') ? 200 : 200000;

        if (count($result) > $minimum_count) {
            $return_value = true;
        } else {
            $return_value = false;
        }

        return $return_value;
    }

    /**
     * Get the users that need to be disabled.
     * All users in the national orgchart get updated if they are pulled from AD
     * the lastUpdated field is always updated regardless if there's any other
     * data that needs to be updated. So it is safe to say that if they haven't
     * been updated within the last 30 hours they are no longer in the AD and should
     * be disabled.
     *
     * @return array
     *
     */
    private function getUserNamesToBeDisabled(): array
    {
        $sql = 'SELECT `userName`
                FROM `employee`
                WHERE `deleted` = 0
                AND `lastUpdated` < (UNIX_TIMESTAMP(NOW()) - 108000)
                AND `lastUpdated` > 0';

        $return_value = $this->db->prepared_query($sql, array());

        return $return_value;
    }

    private function preventRecycledUserName(array $userNames): void
    {
        $deleteTime = $this->disable_time;

        $vars = array(':deleteTime' => $deleteTime);
        $sql = 'UPDATE `employee`
                SET `deleted` = :deleteTime
                WHERE `userName` = :userName;';

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

    private function parseVAdomain($adPath) {
    	$dc = '';
    	$dcSrc = explode(',', $adPath);
    	foreach($dcSrc as $adElement) {
    		if(strpos($adElement, 'DC=') !== false) {
    			$dc .= substr($adElement, 3) . '.';
    		}
    	}
    	$dc = trim($dc, '.');

    	switch($dc) {
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
}
