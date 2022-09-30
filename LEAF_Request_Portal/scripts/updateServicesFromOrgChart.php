<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';
include_once $currDir . '/../db_mysql.php';
include_once $currDir . '/../db_config.php';
include_once $currDir . '/../Login.php';

$db_config = new DB_Config();
$config = new Config();
$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
$db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
$login = new Login($db_phonebook, $db);
$login->setBaseDir('../');
$login->loginUser();

include_once $currDir . '/../' . Config::$orgchartPath . '/config.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Employee.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Group.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Position.php';
include_once $currDir . '/../' . Config::$orgchartPath . '/sources/Tag.php';

$employee = new Orgchart\Employee($db_phonebook, $login);
$group = new Orgchart\Group($db_phonebook, $login);
$position = new Orgchart\Position($db_phonebook, $login);
$tag = new Orgchart\Tag($db_phonebook, $login);
$query_counter = 0;
// update quadrad/pentad/elt nomenclature
$sql_vars = array(':leadershipType' => ucfirst($tag->getParent('service')) . ' Review');
$db->prepared_query('UPDATE dependencies
						SET description = :leadershipType
						WHERE dependencyID = 8', $sql_vars);
$query_counter++;

$sql_vars = array(':leadershipType' => ucfirst($tag->getParent('service')));
$db->prepared_query('UPDATE groups
						SET name = :leadershipType
						WHERE groupID = -1', $sql_vars);
$query_counter++;

// get quadrad groups
$resquadrad = $group->listGroupsByTag($tag->getParent('service'));
$query_counter++;
$db->beginTransaction();

echo 'Clearing out existing users/groups.<br />';

$db->prepared_query('DELETE FROM users WHERE groupID > 1 AND locallyManaged != 1', array());
$db->prepared_query('DELETE FROM `groups` WHERE groupID > 1', array());
$query_counter++;
$query_counter++;

// import quadrads
foreach ($resquadrad as $quadrad)
{
    echo "Synching Quadrad: {$quadrad['groupTitle']}<br />";

    $sql_vars = array(':groupID' => $quadrad['groupID'],
            ':quadrad' => $quadrad['groupTitle'], );

    $db->prepared_query('INSERT INTO groups (groupID, parentGroupID, name)
                            VALUES (:groupID, -1, :quadrad)
                            ON DUPLICATE KEY UPDATE name=:quadrad', $sql_vars);
$query_counter++;
    $leaderGroupID = $group->getGroupLeader($quadrad['groupID']);
$query_counter++;
    $resEmp = $position->getEmployees($leaderGroupID);
    $query_counter++;
    $resEmp = array_merge($resEmp, $group->listGroupEmployees($quadrad['groupID']));
    foreach ($resEmp as $emp)
    {
        if ($emp['userName'] != '')
        {
            $sql_vars = array(':userID' => $emp['userName'],
                          ':groupID' => $quadrad['groupID'], );

            $db->prepared_query('INSERT INTO users (userID, groupID)
                                    VALUES (:userID, :groupID)
                                    ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);
                                    $query_counter++;

            // include the backups of employees
            $backups = $employee->getBackups($emp['empUID']);
            foreach ($backups as $backup)
            {
                $sql_vars = array(':userID' => $backup['userName'],
                              ':groupID' => $quadrad['groupID'],
                              ':backupID' => $emp['userName'], );

                // Add backupID for sync checks
                $db->prepared_query('INSERT INTO users (userID, groupID, backupID)
                                   		 VALUES (:userID, :groupID, :backupID)
                                   		 ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);
                                         $query_counter++;
            }
        }
    }
}

$res = $group->listGroupsByTag('service');
$query_counter++;
$sql_vars = array();
$db->prepared_query('DELETE FROM services WHERE serviceID > 0', array());
$db->prepared_query('DELETE FROM service_chiefs WHERE serviceID > 0 AND locallyManaged != 1 AND
active != 0', array());
$query_counter++;
$query_counter++;
// import services
foreach ($res as $service)
{
    $leader = $position->findRootPositionByGroupTag($group->getGroupLeader($service['groupID']), $tag->getParent('service'));
    $query_counter++;
    $query_counter++;
    $query_counter++;
    if (!is_array($leader))
    {
        return 'invalid service'; // is this correct? we are not in a class method
    }
    $quadID = (isset($leader[0]['groupID'])) ? $leader[0]['groupID'] : null;

    echo "Synching Service: {$service['groupTitle']}<br />";
    $abbrService = isset($service['groupAbbreviation']) ? $service['groupAbbreviation'] : '';
    $sql_vars = array(':serviceID' => $service['groupID'],
                  ':service' => $service['groupTitle'],
                  ':abbrService' => $abbrService,
                  ':groupID' => $quadID, );

    $db->prepared_query('INSERT INTO services (serviceID, service, abbreviatedService, groupID)
                            VALUES (:serviceID, :service, :abbrService, :groupID)
    						ON DUPLICATE KEY UPDATE service=:service, groupID=:groupID', $sql_vars);
$query_counter++;
    $leaderGroupID = $group->getGroupLeader($service['groupID']);
    $query_counter++;
    $resEmp = $position->getEmployees($leaderGroupID);
    $query_counter++;
//    $resEmp = array_merge($resEmp, $group->listGroupEmployees($service['groupID']));
echo __FILE__ . ' Line # ' . __LINE__;
            var_dump($resEmp);
    foreach ($resEmp as $emp)
    {
        if ($emp['userName'] != '')
        {
            $sql_vars = array(':userID' => $emp['userName'],
                          ':serviceID' => $service['groupID'], );

            $db->prepared_query('INSERT INTO service_chiefs (serviceID, userID)
                                    VALUES (:serviceID, :userID)
                                    ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);
$query_counter++;
            // include the backups of employees
            $backups = $employee->getBackups($emp['empUID']);
            $query_counter++;
            echo __FILE__ . ' Line # ' . __LINE__;
            var_dump($backups);
            foreach ($backups as $backup)
            {
                $sql_vars = array(':userID' => $backup['userName'],
                              ':serviceID' => $service['groupID'],
                              ':backupID' => $emp['userName'],  );

                // Add backupID for sync checks
                $db->prepared_query('INSERT INTO service_chiefs (serviceID, userID, backupID)
                                    VALUES (:serviceID, :userID, :backupID)
                                    ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);
                                    $query_counter++;
            }
        }
    }

    // check if this service is also an ELT
    // if so, update groups table
    if ($service['groupID'] == $quadID)
    {
        $sql_vars = array(':groupID' => $service['groupID']);

        $db->prepared_query('DELETE FROM users WHERE groupID=:groupID', $sql_vars);
$query_counter++;
        $resChief = $db->prepared_query('SELECT * FROM service_chiefs
    											WHERE serviceID=:groupID
    												AND active=1', $sql_vars);
                                                    $query_counter++;

        foreach ($resChief as $chief)
        {
            $sql_vars = array(':userID' => $chief['userID'],
                          ':groupID' => $quadID, );
            $db->prepared_query('INSERT INTO users (userID, groupID)
                                   		 VALUES (:userID, :groupID)
                                   		 ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);
                                         $query_counter++;
        }
    }

    //refresh request portal members backups
    $sql_vars = array(':serviceID' => $service['groupID'],);

    $resEmp = $db->prepared_query('SELECT * FROM service_chiefs WHERE serviceID=:serviceID AND active=1', $sql_vars);
    $query_counter++;
    foreach ($resEmp as $emp)
    {
        $empID = $employee->lookupLogin($emp['userID']);
        $query_counter++;
        $backups = $employee->getBackups($empID[0]['empUID']);
        $query_counter++;
        echo __FILE__ . ' Line # ' . __LINE__;
            var_dump($backups);
        foreach ($backups as $backup)
        {
            $sql_vars = array(':userID' => $backup['userName'],
                ':serviceID' => $service['groupID'],
                ':backupID' => $emp['userID'], );

            // Add backupID check for updates
            $db->prepared_query('INSERT INTO service_chiefs (serviceID, userID, backupID)
                                                    VALUES (:serviceID, :userID, :backupID)
                                                    ON DUPLICATE KEY UPDATE serviceID=:serviceID, userID=:userID, backupID=:backupID', $sql_vars);
                                                    $query_counter++;
        }
    }
}

// import other groups
foreach (Config::$orgchartImportTags as $tag)
{
    $res = $group->listGroupsByTag($tag);
$query_counter++;
    foreach ($res as $tgroup)
    {
        echo "Synching Group: {$tgroup['groupTitle']}<br />";

        $sql_vars = array(':groupID' => $tgroup['groupID'],
                ':title' => $tgroup['groupTitle'], );

        $db->prepared_query('INSERT INTO groups (groupID, parentGroupID, name)
                            VALUES (:groupID, NULL, :title)
                            ON DUPLICATE KEY UPDATE name=:title', $sql_vars);
$query_counter++;
        $positions = $group->listGroupPositions($tgroup['groupID']);
        $query_counter++;
        $resEmp = $group->listGroupEmployees($tgroup['groupID']);
        $query_counter++;
        foreach ($positions as $tposition)
        {
            $resEmp = array_merge($resEmp, $position->getEmployees($tposition['positionID']));
        }

        foreach ($resEmp as $emp)
        {
            if ($emp['userName'] != '')
            {
                $sql_vars = array(':userID' => $emp['userName'],
                              ':groupID' => $tgroup['groupID'], );

                $db->prepared_query('INSERT INTO users (userID, groupID)
										VALUES (:userID, :groupID)
										ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);
$query_counter++;
                $res = $db->prepared_query('SELECT * FROM users WHERE userID=:userID AND groupID=:groupID', $sql_vars);
$query_counter++;
                // include the backups of employees
                if ($res[0]['active'] == 1) {
                    $backups = $employee->getBackups($emp['empUID']);
                    $query_counter++;
                    foreach ($backups as $backup) {
                        $sql_vars = array(':userID' => $backup['userName'],
                            ':groupID' => $tgroup['groupID'],
                            ':backupID' => $emp['userName'],);

                        // Add backupID for sync checks
                        $db->prepared_query('INSERT INTO users (userID, groupID, backupID)
										VALUES (:userID, :groupID, :backupID)
										ON DUPLICATE KEY UPDATE userID=:userID', $sql_vars);
                                        $query_counter++;
                    }
                }
            }
        }
        //refresh request portal members backups
        $sql_vars = array(':groupID' => $tgroup['groupID'],);

        $resEmp = $db->prepared_query('SELECT * FROM users WHERE groupID=:groupID AND active=1', $sql_vars);
        $query_counter++;
        foreach ($resEmp as $emp)
        {
            $empID = $employee->lookupLogin($emp['userID']);
            $query_counter++;
	    if (isset($empID[0]['empUID'])) {
	        $backups = $employee->getBackups($empID[0]['empUID']);
            $query_counter++;
	        foreach ($backups as $backup)
	        {
		    $sql_vars = array(':userID' => $backup['userName'],
		        ':groupID' => $tgroup['groupID'],
		        ':backupID' => $emp['userID'], );

		    // Add backupID check for updates
		    $db->prepared_query('INSERT INTO users (userID, groupID, backupID)
						    VALUES (:userID, :groupID, :backupID)
						    ON DUPLICATE KEY UPDATE userID=:userID, groupID=:groupID, backupID=:backupID', $sql_vars);
                            $query_counter++;
	        }
	    }
        }
    }
}

$groupIDs = $db->query('SELECT category_privs.groupID
                        FROM category_privs
                        LEFT JOIN groups USING (groupID)
                        WHERE groups.groupID IS NULL;');
                        $query_counter++;
foreach($groupIDs as $groupIDToDelete)
{

    $db->prepared_query('DELETE FROM category_privs WHERE groupID = :groupID', array(':groupID' => $groupIDToDelete['groupID']));
    $query_counter++;
}

$db->commitTransaction();
echo '# of queries run '.$query_counter;
echo '<br />... Done.';
