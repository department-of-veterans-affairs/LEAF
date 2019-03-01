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

    $sql = "UPDATE employee
            SET empUID = CASE";
    foreach($nationalEmployeeData as $natEmp)
    {
        $sql .= "\nWHEN userName = '".$natEmp['userName']."' THEN '".$natEmp['empUID']."'";

    }
    $sql .= "\nEND;";

    return $sql;
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
        'employee_privileges' => ['empUID'],
        'relation_employee_backup' => ['empUID','backupEmpUID','approverUserName'],
        'relation_group_employee' => ['empUID'],
        'relation_position_employee' => ['empUID'],
        'group_data' => ['author'],
        'group_data_history' => ['author'],
        'position_data' => ['author'],
        'position_data_history' => ['author'],
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
                    if($column === 'empUID' || $column === 'backupEmpUID')
                    {
                        $originalValue = $employee['oldEmpUID'];
                    }
                    else
                    {
                        $originalValue = $employee['userName'];
                    }
                    $sql5 .= "\nWHEN $column = '$originalValue' THEN '".$employee['empUID']."'";
                }

                $sql5 .= "\nEND;";
                $sql5ToPrint .= "\n".$sql5;
                $db->exec($sql5);
            }
        }
        
        $sql6 = 'ALTER TABLE employee DROP COLUMN oldEmpUID;
                SET FOREIGN_KEY_CHECKS=1;';
        $db->exec($sql6);
        // echo $sql1 . "\n";
        // echo $sql2 . "\n";
        // echo $sql3 . "\n";
        // echo $sql4 . "\n";
        // echo $sql5ToPrint . "\n";
        // echo $sql6 . "\n";
        $db->commit();
    }
    catch(Exception $e) 
    {
        echo $e->getMessage();
        $db->rollBack();
    }
}

$nationalOG = ['dbHost' => 'localhost', 'dbName' => 'UUID_national', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'];
//do national
updateNexus($nationalOG);
//build update script for individual nexus
$nationalEmpUIDImport = buildUpdateScriptFromNationalOGForNexus($nationalOG);
//do individual
updateNexus(['dbHost' => 'localhost', 'dbName' => 'UUID_local_nexus', 'dbUser' => 'testuser', 'dbPass' => 'testuserpass'], $nationalEmpUIDImport);

//do I base deletedusers off of national only?
//what if newer user isnt present in the local(sp?) nexus
?>