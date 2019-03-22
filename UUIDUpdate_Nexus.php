<?php

function buildUpdateScriptFromNationalOGForNexus($nationalDbInfo)
{
    $db = new PDO(
        "mysql:host={$nationalDbInfo['dbHost']};dbname={$nationalDbInfo['dbName']}",
        $nationalDbInfo['dbUser'],
        $nationalDbInfo['dbPass'],
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    $nationalEmployeeData = $db->query('select employee.* from employee order By employee.lastUpdated');

    // $nexusSQL = "UPDATE employee
    //                 SET empUID = CASE";
    // $portalSQL = "UPDATE users
    //                 SET empUID = CASE";
    $portalSQL = "";
    $nexusSQL = "";
    foreach($nationalEmployeeData as $key => $natEmp)
    {
        //$nexusSQL .= PHP_EOL."WHEN userName = '".$natEmp['userName']."' THEN '".$natEmp['empUID']."'";
        //$portalSQL .= PHP_EOL."WHEN userID = '".$natEmp['userName']."' THEN '".$natEmp['empUID']."'";
        $nexusSQL  .= PHP_EOL. "UPDATE employee SET empUID = '".$natEmp['empUID']."' WHERE userName = \"".$natEmp['userName']."\";"."-- $key";
        $portalSQL .= PHP_EOL. "UPDATE users    SET empUID = '".$natEmp['empUID']."' WHERE userID   = \"".$natEmp['userName']."\";"."-- $key";
        
    }
    // $nexusSQL .= PHP_EOL."ELSE userName
    //                 END;";
    // $portalSQL .= PHP_EOL."ELSE userID
    //                 END;";

    return ['nexusImport' => $nexusSQL, 'portalImport' => $portalSQL];
}


function prepareNexus($dbInfo)
{
    echo " setting up " . (new \DateTime())->format('H:i:s')." " . memory_get_usage ().PHP_EOL;
    $db = new PDO(
        "mysql:host={$dbInfo['dbHost']};dbname={$dbInfo['dbName']}",
        $dbInfo['dbUser'],
        $dbInfo['dbPass'],
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
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

function finishUpNexus($dbInfo)
{
    echo " finishing up " . (new \DateTime())->format('H:i:s')." " . memory_get_usage ().PHP_EOL;
    $db = new PDO(
        "mysql:host={$dbInfo['dbHost']};dbname={$dbInfo['dbName']}",
        $dbInfo['dbUser'],
        $dbInfo['dbPass'],
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
    $sql = "ALTER TABLE employee DROP COLUMN oldEmpUID;

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

function preparePortal($dbInfo)
{
    echo " setting up " . (new \DateTime())->format('H:i:s')." " . memory_get_usage ().PHP_EOL;
    $db = new PDO(
        "mysql:host={$dbInfo['dbHost']};dbname={$dbInfo['dbName']}",
        $dbInfo['dbUser'],
        $dbInfo['dbPass'],
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
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

function updateNexus($dbInfo, $nationalEmpUIDImport='')
{
    $db = new PDO(
        "mysql:host={$dbInfo['dbHost']};dbname={$dbInfo['dbName']}",
        $dbInfo['dbUser'],
        $dbInfo['dbPass'],
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
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
        from employee join emails_table on (employee.oldEmpUID = emails_table.empUID) WHERE employee.empUID IS NOT NULL order By employee.lastUpdated;';
        $res = $db->query($sqlEmployeeInfo);

        $empUIDsKeyedByEmail = array();
        $employeesKeyedByOldEmpUIDs = array();
        $empUIDsToDelete = array();
        foreach ($res as $employeeData)
        {
            $employee = ['oldEmpUID' => $employeeData['oldEmpUID'], 'userName' => $employeeData['userName'], 'empUID' => $employeeData['empUID']];

            if ($employeeData['email'] != null && $employeeData['email'] != '' && array_key_exists($employeeData['email'], $empUIDsKeyedByEmail))
            {//if the email was already found
            //set this employee to be disabled
                $empUIDsToDelete[] = $employeeData['empUID'];
                //associate this employee with the already found employee(same employee, different username)
                //$employee['empUID'] = $empUIDsKeyedByEmail[$employeeData['email']];
            }
            else if($employeeData['email'] != null && $employeeData['email'] != '')
            { //email not found
            //add to list of found emails w/ associated empUIDs
                $empUIDsKeyedByEmail[$employeeData['email']] = $employeeData['empUID'];
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

function updatePortal($dbInfo, $nationalEmpUIDImport)
{
    $db = new PDO(
        "mysql:host={$dbInfo['dbHost']};dbname={$dbInfo['dbName']}",
        $dbInfo['dbUser'],
        $dbInfo['dbPass'],
        array(PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION)
    );
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

ini_set('memory_limit', '-1');

$nationalOG = ['dbHost' => 'localhost', 'dbName' => 'national_orgchart', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'];

//do national
echo "Updating National Org Chart: ";
//updateNexus($nationalOG);
//build update script for individual nexus
$nationalEmpUIDImport = buildUpdateScriptFromNationalOGForNexus($nationalOG);
//printf("\033[0G\033[2K"."Updating National Org Chart: Done");

$localNexusArray = [
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_orgchart', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_orgchart', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn23_437_orgchart', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_orgchart', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn10_583_orgchart', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn10_610_orgchart', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
];
$localPortalArray = [
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_pcs', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_cmc_communications_request_modernization', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_cmcvamc', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_facilities', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_has', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_electronic_rmc_process', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_radiology', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_hr', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_fiscal', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_cmcvamc_health_informatics', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_cmcvamc_pharmacy', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_itops', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn4_642_quality_management', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],

    ['dbHost' => 'localhost', 'dbName' => 'visn10_583_indianapolis_request_system', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],

    ['dbHost' => 'localhost', 'dbName' => 'visn10_610_nihcs_healthcare_informatics_change_requests', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn10_610_nihcs_healthcare_informatics_change_requests-leaf', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],

    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_resources', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_logistics', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_ofpd_project_tracking', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_oit_equipment_request', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_palo_alto_pao', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_tarf', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_vapahcs_vcs_promo_requests', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_resources_test', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn21_640_vcs_promotional_fund', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],

    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_accreditation', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_stopcodes', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_distro', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_myhealthevet_work_order', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_onboarding', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_resources', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_board_actions', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_it_requests', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_tibor_rubin_cac', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_hr_helpdesk_requests', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_hr', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_organizational_charts', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_hpt_outprocessing', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn22_600_has_clinic_profile_group', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],

    ['dbHost' => 'localhost', 'dbName' => 'visn23_437_nurse_executive', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn23_437_fargo_vahcs_education_service_line', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'visn23_437_waiverrequests', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],


    
];

//do individual nexi
echo PHP_EOL.PHP_EOL."updating local nexi".PHP_EOL;
foreach($localNexusArray as $key => $connectionDetails)
{
    //progressBar($key+1, count($localNexusArray));
    echo PHP_EOL." Doing " . $connectionDetails['dbName'] . " " . (new \DateTime())->format('H:i:s')." ".memory_get_usage () . PHP_EOL;
    prepareNexus($connectionDetails);
    updateNexus($connectionDetails, $nationalEmpUIDImport['nexusImport']);
    finishUpNexus($connectionDetails);
}

//do portal
echo PHP_EOL.PHP_EOL."updating portals".PHP_EOL;
foreach($localPortalArray as $key => $connectionDetails)
{
    //progressBar($key+1, count($localPortalArray));
    echo PHP_EOL." Doing " . $connectionDetails['dbName'] . " " . (new \DateTime())->format('H:i:s')." ".memory_get_usage () . PHP_EOL;
    preparePortal($connectionDetails);
    updatePortal($connectionDetails, $nationalEmpUIDImport['portalImport']);
}

echo PHP_EOL.PHP_EOL."Finished";
?>