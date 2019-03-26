<?php

function buildUpdateScriptFromNationalOGForNexus($db)
{
    $nationalEmployeeData = $db->query('select employee.* from employee order By employee.lastUpdated');

    $portalSQL = "";
    $nexusSQL = "";
    foreach($nationalEmployeeData as $key => $natEmp)
    {
        $nexusSQL  .= PHP_EOL. "UPDATE employee SET empUID = '".$natEmp['empUID']."' WHERE userName = \"".$natEmp['userName']."\";"."-- $key";
        $portalSQL .= PHP_EOL. "UPDATE users    SET empUID = '".$natEmp['empUID']."' WHERE userID   = \"".$natEmp['userName']."\";"."-- $key";
    }
    return ['nexusImport' => $nexusSQL, 'portalImport' => $portalSQL];
}


function prepareNexus($db)
{
    $sql = "ALTER TABLE `employee_data`
    ADD INDEX `author` (`author`);
    ALTER TABLE `employee_data_history`
    ADD INDEX `author` (`author`);
    ALTER TABLE `employee_privileges`
    ADD INDEX `UID` (`UID`);
    ALTER TABLE `relation_employee_backup`
    ADD INDEX `backupEmpUID` (`backupEmpUID`);
    ALTER TABLE `relation_employee_backup`
    ADD INDEX `approverUserName` (`approverUserName`);
    ALTER TABLE `group_data`
    ADD INDEX `author` (`author`);
    ALTER TABLE `group_data_history`
    ADD INDEX `author` (`author`);
    ALTER TABLE `position_data`
    ADD INDEX `author` (`author`);
    ALTER TABLE `position_data_history`
    ADD INDEX `author` (`author`);
    ALTER TABLE `group_privileges`
    ADD INDEX `UID` (`UID`);
    ALTER TABLE `indicator_privileges`
    ADD INDEX `UID` (`UID`);
    ALTER TABLE `position_privileges`
    ADD INDEX `UID` (`UID`);
    
    ALTER TABLE `employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL DEFAULT '0' FIRST;
    ALTER TABLE `employee_data` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `employee_data_history` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `employee_privileges` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `relation_employee_backup` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `relation_employee_backup` CHANGE `backupEmpUID` `backupEmpUID` varchar(36) NOT NULL;
    ALTER TABLE `relation_group_employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `relation_position_employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
    
    ALTER TABLE `employee_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;
    ALTER TABLE `group_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;
    ALTER TABLE `indicator_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;
    ALTER TABLE `position_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;
    
    ALTER TABLE `employee_data` CHANGE `author` `author` varchar(36) NOT NULL;
    ALTER TABLE `employee_data_history` CHANGE `author` `author` varchar(36) NOT NULL;
    ALTER TABLE `group_data` CHANGE `author` `author` varchar(36) NOT NULL;
    ALTER TABLE `group_data_history` CHANGE `author` `author` varchar(36) NOT NULL;
    ALTER TABLE `position_data` CHANGE `author` `author` varchar(36) NOT NULL;
    ALTER TABLE `position_data_history` CHANGE `author` `author` varchar(36) NOT NULL;
    
    ALTER TABLE `relation_employee_backup` CHANGE `approverUserName` `approverUserName` varchar(36);

    ALTER TABLE employee CHANGE `empUID` `oldEmpUID` int; 
    ALTER TABLE `employee` ADD `empUID` varchar(36) FIRST;
    ";
    $db->beginTransaction();
    $db->exec($sql);
    $db->commit();
}

function getUniqueEmailCount($db)
{
    $sql = "SELECT count(*) AS count
            FROM (
                    SELECT employee.userName, employee_data.data AS email
                    FROM employee
                    LEFT JOIN employee_data on (employee.empUID = employee_data.empUID and indicatorID = 6)
                    WHERE employee.deleted = 0
                    GROUP BY IF(email = '' or email is null, employee.userName, email)
                )as a;";
    $res = $db->query($sql)->fetchAll();

    return $res[0]['count'];
}

function getActiveUserCount($db)
{
    $sql = "SELECT count(*) AS count
            FROM employee 
            WHERE deleted = 0;";
    $res = $db->query($sql)->fetchAll();

    return $res[0]['count'];
}

function duplicateActiveEmails($db)
{
    $sql = "SELECT count(*) as count
            FROM (
                    SELECT employee_data.data
                    FROM employee
                    LEFT JOIN employee_data USING (empUID)
                    WHERE employee_data.indicatorID = 6
                    AND employee.deleted = 0
                    AND employee_data.data != ''
                    AND employee_data.data IS NOT NULL
                    GROUP BY employee_data.data
                    HAVING count(employee.userName) > 1
                ) as a;";

    $res = $db->query($sql)->fetchAll();

    return $res[0]['count'];
}

function finishUpNexus($db)
{
    echo " finishing up " . (new \DateTime())->format('H:i:s')." " . memory_get_usage ().PHP_EOL;
    $sql = "ALTER TABLE employee DROP COLUMN oldEmpUID;
            ALTER TABLE employee ADD PRIMARY KEY(empUID);

    ALTER TABLE `employee_data`
    DROP INDEX `author`;
    ALTER TABLE `employee_data_history`
    DROP INDEX `author`;
    ALTER TABLE `employee_privileges`
    DROP INDEX `UID`;
    ALTER TABLE `relation_employee_backup`
    DROP INDEX `backupEmpUID`;
    ALTER TABLE `relation_employee_backup`
    DROP INDEX `approverUserName`;
    ALTER TABLE `group_data`
    DROP INDEX `author`;
    ALTER TABLE `group_data_history`
    DROP INDEX `author`;
    ALTER TABLE `position_data`
    DROP INDEX `author`;
    ALTER TABLE `position_data_history`
    DROP INDEX `author`;
    ALTER TABLE `group_privileges`
    DROP INDEX `UID`;
    ALTER TABLE `indicator_privileges`
    DROP INDEX `UID`;
    ALTER TABLE `position_privileges`
    DROP INDEX `UID`;
    ";
    $db->beginTransaction();
    $db->exec($sql);
    $db->commit();
}

function preparePortal($db)
{
    echo " setting up " . (new \DateTime())->format('H:i:s')." " . memory_get_usage ().PHP_EOL;
    $sql = "ALTER TABLE `action_history` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `approvals` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `data` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `data_extended` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `data_history` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `notes` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `records` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `service_chiefs` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `signatures` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `tags` CHANGE `userID` `empUID` varchar(36) NOT NULL;
    ALTER TABLE `users` ADD `empUID` varchar(36) NOT NULL;
    ";
    $db->beginTransaction();
    $db->exec($sql);
    $db->commit();
}

function updateNexus($db, $nationalEmpUIDImport='')
{
    $tablesWithEmpUID = [
        //empUID's
        'employee_data' => ['empUID','author'],
        'employee_data_history' => ['empUID','author'],
        'employee_privileges' => ['empUID', 'UID'],
        'relation_employee_backup' => ['empUID','backupEmpUID','approverUserName'],
        'relation_group_employee' => ['empUID'],
        'relation_position_employee' => ['empUID'],
        'group_data' => ['author'],
        'group_data_history' => ['author'],
        'position_data' => ['author'],
        'position_data_history' => ['author'],

        'group_privileges' => ['UID'],
        'indicator_privileges' => ['UID'],
        'position_privileges' => ['UID'],
    ];
    $db->beginTransaction();
    try
    {
        if ($nationalEmpUIDImport != '')
        {
            $sqlNewEmpUID = $nationalEmpUIDImport;
        }
        else
        {
            $sqlNewEmpUID = 'UPDATE employee SET empUID=uuid();';
        }
        $db->exec($sqlNewEmpUID); 
        //if any empUID is null, set to oldEmpUID
        $sqlFillInEmpUIDBlanks = "UPDATE employee SET empUID=CONCAT('not_in_national_', oldEmpUID) WHERE empUID IS NULL;";
        $db->query($sqlFillInEmpUIDBlanks);
        
        $createTempTable = "CREATE TEMPORARY TABLE emails_table
                            (INDEX empUId_ky (empUID))
                            SELECT empUID, data FROM employee_data 
                            where indicatorID = 6;";
        $db->query($createTempTable);
        
        $sqlEmployeeInfo = 'select employee.empUID, employee.oldEmpUID, employee.userName, emails_table.data as email 
        from employee left join emails_table on (employee.oldEmpUID = emails_table.empUID) ORDER BY employee.lastUpdated DESC;';
        $res = $db->query($sqlEmployeeInfo);

        $empUIDsKeyedByEmail = array();
        $employeesKeyedByOldEmpUIDs = array();
        $empUIDsToDelete = array();
        foreach ($res as $employeeData)
        {
            $employee = ['oldEmpUID' => $employeeData['oldEmpUID'], 'userName' => $employeeData['userName'], 'empUID' => $employeeData['empUID']];

            $emailToLower = strtolower($employeeData['email']);
            if ($emailToLower != null && $emailToLower != '' && array_key_exists($emailToLower, $empUIDsKeyedByEmail))
            {//if the email was already found
            //set this employee to be disabled
                $empUIDsToDelete[] = $employeeData['empUID'];
                //associate this employee with the already found employee(same employee, different username)
                //$employee['empUID'] = $empUIDsKeyedByEmail[$emailToLower];
            }
            else if($emailToLower != null && $emailToLower != '')
            { //email not found
            //add to list of found emails w/ associated empUIDs
                $empUIDsKeyedByEmail[$emailToLower] = $employeeData['empUID'];
            }

            //add empUID to list
            $employeesKeyedByOldEmpUIDs[] = $employee;
        }
        if(count($empUIDsToDelete))
        {
            $sqlDeleteDuplicateEmployees = 'update employee set deleted = '.time().' where empUID in (' . "'" . implode("','",$empUIDsToDelete) . "'" . ');';
            $db->exec($sqlDeleteDuplicateEmployees);
        }
        
        foreach ($tablesWithEmpUID as $table => $columns)
        {
            foreach ($columns as $column)
            {
                $sqlForColumn = "";
                foreach ($employeesKeyedByOldEmpUIDs as $key => $employee)
                {
                    $newValue = $employee['empUID'];
                    if($column === 'empUID' || $column === 'backupEmpUID' || $column === 'UID')
                    {
                        $originalValue = $employee['oldEmpUID'];
                    }
                    else
                    {
                        $originalValue = $employee['userName'];
                    }
                    $sqlForColumn_part = "UPDATE $table -- $key
                                SET $column = '$newValue'
                                WHERE $column = \"$originalValue\" ";
                    if($column != 'UID')
                    {
                        $sqlForColumn_part .= ";";
                    }
                    else
                    {
                        $sqlForColumn_part .= PHP_EOL."AND categoryID = 'employee';";
                    } 
                    $sqlForColumn .= PHP_EOL.$sqlForColumn_part;
                }
                $db->exec($sqlForColumn);
            }
        }
        $db->commit();
    }
    catch(Exception $e) 
    {
        echo $e->getMessage();
        $db->rollBack();
    }
}

function updatePortal($db, $nationalEmpUIDImport)
{
    $tablesWithEmpUID = [
        //empUID's
        'action_history' => ['empUID'], 
        'approvals' => ['empUID'], 
        'data' => ['empUID'], 
        'data_extended' => ['empUID'], 
        'data_history' => ['empUID'], 
        'notes' => ['empUID'], 
        'records' => ['empUID'], 
        'service_chiefs' => ['empUID'], 
        'signatures' => ['empUID'], 
        'tags' => ['empUID'], 
    ];
    $db->beginTransaction();
    try
    {
        $db->exec($nationalEmpUIDImport);
        //if any empUID is null, set to userID
        $sqlFillInEmpUIDBlanks = "UPDATE users SET empUID=CONCAT('not_in_national_', userID) WHERE empUID IS NULL;";
        $db->query($sqlFillInEmpUIDBlanks);

        $sqlEmployeeInfo = 'select * from users;';
        $res = $db->query($sqlEmployeeInfo);

        $employeesKeyedByOldEmpUIDs = array();
        foreach ($res as $employeeData)
        {
            $employee = ['userID' => $employeeData['userID'], 'empUID' => $employeeData['empUID']];

            //add empUID to list
            $employeesKeyedByOldEmpUIDs[] = $employee;
        }
        foreach ($tablesWithEmpUID as $table => $columns)
        {
            foreach ($columns as $column)
            {
                $sqlForColumn = "";
                foreach ($employeesKeyedByOldEmpUIDs as $key => $employee)
                {
                    
                    $originalValue = $employee['userID'];
                    $newValue = $employee['empUID'];
                    $sqlForColumn_part = "UPDATE $table -- $key
                                            SET $column = '$newValue'
                                            WHERE $column = \"$originalValue\"; ";

                    $sqlForColumn .= PHP_EOL.$sqlForColumn_part;
                }
                //echo $sqlForColumn;
                $db->exec($sqlForColumn);
            }
        }
        $db->commit();
    }
    catch(Exception $e) 
    {
        echo $e->getMessage();
        $db->rollBack();
    }
}







function progressBar($done, $total) {
    $perc = floor(($done / $total) * 100);
    $left = 100 - $perc;
    $write = sprintf("\033[0G\033[2K[%'={$perc}s>%-{$left}s] - $perc%% - $done/$total", "", "");
    fwrite(STDERR, $write);
}

$dbHOST = $argv[1];
$dbUser = $argv[2];
$dbPass = $argv[3];

ini_set('memory_limit', '-1');

$nationalOG = 'national_orgchart';
$db = new PDO(
    "mysql:host={$dbHOST};dbname={$nationalOG}",
    $dbUser,
    $dbPass,
    array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
);
//build update script for individual nexus
$nationalEmpUIDImport = buildUpdateScriptFromNationalOGForNexus($db);

$localNexusArray = [
    //'visn22_600_orgchart',
    'visn4_642_orgchart',
    // 'visn23_437_orgchart',
    // 'visn21_640_orgchart',
    // 'visn10_583_orgchart',
    // 'visn10_610_orgchart',
];
$localPortalArray = [
    'visn4_642_pcs',
    'visn4_642_cmc_communications_request_modernization',
    'visn4_642_cmcvamc',
    'visn4_642_facilities',
    'visn4_642_has',
    'visn4_642_electronic_rmc_process',
    'visn4_642_radiology',
    'visn4_642_hr',
    'visn4_642_fiscal',
    'visn4_642_cmcvamc_health_informatics',
    'visn4_642_cmcvamc_pharmacy',
    'visn4_642_itops',
    'visn4_642_quality_management',

    // 'visn10_583_indianapolis_request_system',

    // 'visn10_610_nihcs_healthcare_informatics_change_requests',
    // 'visn10_610_nihcs_healthcare_informatics_change_requests-leaf',

    // 'visn21_640_resources',
    // 'visn21_640_logistics',
    // 'visn21_640_ofpd_project_tracking',
    // 'visn21_640_oit_equipment_request',
    // 'visn21_640_palo_alto_pao',
    // 'visn21_640_tarf',
    // 'visn21_640_vapahcs_vcs_promo_requests',
    // 'visn21_640_resources_test',
    // 'visn21_640_vcs_promotional_fund',

    'visn22_600_accreditation',
    'visn22_600_stopcodes',
    'visn22_600_distro',
    'visn22_600_myhealthevet_work_order',
    'visn22_600_onboarding',
    'visn22_600_resources',
    'visn22_600_board_actions',
    'visn22_600_it_requests',
    'visn22_600_tibor_rubin_cac',
    'visn22_600_hr_helpdesk_requests',
    'visn22_600_hr',
    'visn22_600_organizational_charts',
    'visn22_600_hpt_outprocessing',
    'visn22_600_has_clinic_profile_group',

    // 'visn23_437_nurse_executive',
    // 'visn23_437_fargo_vahcs_education_service_line',
    // 'visn23_437_waiverrequests',
];

//do individual nexi
echo PHP_EOL.PHP_EOL."updating local nexi".PHP_EOL;
foreach($localNexusArray as $key => $dbName)
{
    echo PHP_EOL." Doing " . $dbName . " " . (new \DateTime())->format('H:i:s')." ".memory_get_usage () . PHP_EOL;
    $db = new PDO(
        "mysql:host={$dbHOST};dbname={$dbName}",
        $dbUser,
        $dbPass,
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );

    $numberOfUnique = getUniqueEmailCount($db);
    prepareNexus($db);
    updateNexus($db, $nationalEmpUIDImport['nexusImport']);
    finishUpNexus($db);
    $numberOfActive = getActiveUserCount($db);

    $duplicates = duplicateActiveEmails($db);

    echo "active unique emails: " . $numberOfUnique . ", # of active users: " . $numberOfActive . ", duplicate active emails: " . $duplicates;
    if($numberOfUnique === $numberOfActive && $duplicates === '0')
    {
        echo " All is well.";
    }
    else
    {
        echo PHP_EOL."There was a problem. Unique emails should equal active users. And there should be no duplicate active emails.".PHP_EOL;
    }
}

//do portal
echo PHP_EOL.PHP_EOL."updating portals".PHP_EOL;
foreach($localPortalArray as $key => $dbName)
{
    echo PHP_EOL." Doing " . $dbName . " " . (new \DateTime())->format('H:i:s')." ".memory_get_usage () . PHP_EOL;
    $db = new PDO(
        "mysql:host={$dbHOST};dbname={$dbName}",
        $dbUser,
        $dbPass,
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );

    preparePortal($db);
    updatePortal($db, $nationalEmpUIDImport['portalImport']);
}

echo PHP_EOL.PHP_EOL."Finished";
?>