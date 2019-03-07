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

    $nexusSQL = "UPDATE employee
                    SET empUID = CASE";

    $portalSQL = "UPDATE users
                    SET empUID = CASE";
    foreach($nationalEmployeeData as $natEmp)
    {
        $nexusSQL .= PHP_EOL."WHEN userName = '".$natEmp['userName']."' THEN '".$natEmp['empUID']."'";
        $portalSQL .= PHP_EOL."WHEN userID = '".$natEmp['userName']."' THEN '".$natEmp['empUID']."'";
    }
    $nexusSQL .= PHP_EOL."ELSE userName
                    END;";
    $portalSQL .= PHP_EOL."ELSE userID
                    END;";

    return ['nexusImport' => $nexusSQL, 'portalImport' => $portalSQL];
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
        $sql1 = 'SET FOREIGN_KEY_CHECKS=0;
            ALTER TABLE employee CHANGE `empUID` `oldEmpUID` int; 
            ALTER TABLE `employee` ADD `empUID` varchar(36) FIRST;';
        $db->exec($sql1);
        if ($nationalEmpUIDImport != '')
        {
            $sql2 = $nationalEmpUIDImport;
        }
        else
        {
            $sql2 = 'UPDATE employee SET empUID=uuid();';
        }
        $db->exec($sql2);

        $sql3 = 'select employee.*, employee_data.data as email from employee left join employee_data on (employee.oldEmpUID = employee_data.empUID && indicatorID = 6) order By employee.lastUpdated';
        $res = $db->query($sql3);

        $empUIDsKeyedByEmail = array();
        $employeesKeyedByOldEmpUIDs = array();
        $empUIDsToDelete = array();
        foreach ($res as $employeeData)
        {
            $employee = ['oldEmpUID' => $employeeData['oldEmpUID'], 'userName' => $employeeData['userName'], 'empUID' => $employeeData['empUID']];

            if ($employeeData['email'] != null && array_key_exists($employeeData['email'], $empUIDsKeyedByEmail))
            {//if the email was already found
            //set this employee to be disabled
                $empUIDsToDelete[] = $employeeData['empUID'];
                //associate this employee with the already found employee(same employee, different username)
                $employee['empUID'] = $empUIDsKeyedByEmail[$employeeData['email']];
            }
            else if($employeeData['email'] != null)
            { //email not found
            //add to list of found emails w/ associated empUIDs
                $empUIDsKeyedByEmail[$employeeData['email']] = $employeeData['empUID'];
            }

            //add empUID to list
            $employeesKeyedByOldEmpUIDs[] = $employee;
        }
        if(count($empUIDsToDelete))
        {
            $sql4 = 'update employee set deleted = time() where oldEmpUID in (' . implode($empUIDsToDelete) . ');';
            $db->exec($sql4);
        }
        $sql5ToPrint = '';
        foreach ($tablesWithEmpUID as $table => $columns)
        {
            foreach ($columns as $column)
            {
                $sql5 = "UPDATE $table
                            SET $column = CASE";
                foreach ($employeesKeyedByOldEmpUIDs as $employee)
                {
                    if($column === 'empUID' || $column === 'backupEmpUID' || $column === 'UID')
                    {
                        $originalValue = $employee['oldEmpUID'];
                    }
                    else
                    {
                        $originalValue = $employee['userName'];
                    }
                    $sql5 .= PHP_EOL."WHEN $column = '$originalValue' THEN '".$employee['empUID']."'";
                }

                if($column != 'UID')
                {
                    $sql5 .= PHP_EOL."ELSE $column
                                END;";
                }
                else
                {
                    $sql5 .= PHP_EOL."ELSE $column
                                END
                                WHERE categoryID = 'employee'";
                }
                
                $sql5ToPrint .= PHP_EOL.$sql5;
                $db->exec($sql5);
            }
        }
        
        $sql6 = 'ALTER TABLE employee DROP COLUMN oldEmpUID;
                SET FOREIGN_KEY_CHECKS=1;';
        $db->exec($sql6);
        $db->commit();
    }
    catch(Exception $e) 
    {
        echo $e->getMessage();
        echo $sql1 . PHP_EOL;
        echo $sql2 . PHP_EOL;
        echo $sql3 . PHP_EOL;
        echo $sql4 . PHP_EOL;
        echo $sql5ToPrint . PHP_EOL;
        echo $sql6 . PHP_EOL;
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
        $sql1 = 'SET FOREIGN_KEY_CHECKS=0;';
        $db->exec($sql1);
        $db->exec($nationalEmpUIDImport);
        $sql3 = 'select * from users;';
        $res = $db->query($sql3);

        $employeesKeyedByOldEmpUIDs = array();
        foreach ($res as $employeeData)
        {
            $employee = ['userID' => $employeeData['userID'], 'empUID' => $employeeData['empUID']];

            //add empUID to list
            $employeesKeyedByOldEmpUIDs[] = $employee;
        }
        $sql5ToPrint = '';
        foreach ($tablesWithEmpUID as $table => $columns)
        {
            foreach ($columns as $column)
            {
                $sql5 = "UPDATE $table
                            SET $column = CASE";
                foreach ($employeesKeyedByOldEmpUIDs as $employee)
                {
                    
                    $originalValue = $employee['userID'];
                    $sql5 .= PHP_EOL."WHEN $column = '$originalValue' THEN '".$employee['empUID']."'";

                }
                $sql5 .= PHP_EOL."ELSE $column
                            END;";
                
                $sql5ToPrint .= PHP_EOL.$sql5;
                $db->exec($sql5);
            }
        }
        
        $sql6 = 'SET FOREIGN_KEY_CHECKS=1;';
        $db->exec($sql6);
        $db->commit();
    }
    catch(Exception $e) 
    {
        echo $e->getMessage();
        echo $sql1 . PHP_EOL;
        echo $sql2 . PHP_EOL;
        echo $sql3 . PHP_EOL;
        echo $sql4 . PHP_EOL;
        echo $sql5ToPrint . PHP_EOL;
        echo $sql6 . PHP_EOL;
        $db->rollBack();
    }
}
function progressBar($done, $total) {
    $perc = floor(($done / $total) * 100);
    $left = 100 - $perc;
    $write = sprintf("\033[0G\033[2K[%'={$perc}s>%-{$left}s] - $perc%% - $done/$total", "", "");
    fwrite(STDERR, $write);
}


$nationalOG = ['dbHost' => 'localhost', 'dbName' => 'UUID_national', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'];

//do national
echo "Updating National Org Chart: ";
updateNexus($nationalOG);
//build update script for individual nexus
$nationalEmpUIDImport = buildUpdateScriptFromNationalOGForNexus($nationalOG);
printf("\033[0G\033[2K"."Updating National Org Chart: Done");

$localNexusArray = [
    ['dbHost' => 'localhost', 'dbName' => 'UUID_local_nexus', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'UUID_local_nexus_2', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
];
$localPortalArray = [
    ['dbHost' => 'localhost', 'dbName' => 'UUID_portal', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    ['dbHost' => 'localhost', 'dbName' => 'UUID_portal_2', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'],
    
];

//do individual nexi
echo PHP_EOL.PHP_EOL."updating local nexi".PHP_EOL;
foreach($localNexusArray as $key => $connectionDetails)
{
    progressBar($key+1, count($localNexusArray));
    updateNexus($connectionDetails, $nationalEmpUIDImport['nexusImport']);
}

//do portal
echo PHP_EOL.PHP_EOL."updating portals".PHP_EOL;
foreach($localPortalArray as $key => $connectionDetails)
{
    progressBar($key+1, count($localPortalArray));
    updatePortal($connectionDetails, $nationalEmpUIDImport['portalImport']);
}

echo PHP_EOL.PHP_EOL."Finished";
?>