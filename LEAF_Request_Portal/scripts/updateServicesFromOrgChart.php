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

$res = $group->listGroupsByTag('service');

// update quadrad/pentad/elt nomenclature
$vars = array(':leadershipType' => ucfirst($tag->getParent('service')) . ' Review');
$db->prepared_query('UPDATE dependencies
						SET description = :leadershipType
						WHERE dependencyID = 8', $vars);

$vars = array(':leadershipType' => ucfirst($tag->getParent('service')));
$db->prepared_query('UPDATE groups
						SET name = :leadershipType
						WHERE groupID = -1', $vars);

// get quadrad groups
$resquadrad = $group->listGroupsByTag($tag->getParent('service'));

$db->beginTransaction();

echo 'Clearing out existing users/groups.<br />';

$db->prepared_query('DELETE FROM users WHERE groupID > 1 AND locallyManaged != 1', array());
$db->prepared_query('DELETE FROM `groups` WHERE groupID > 1', array());

// import quadrads
foreach ($resquadrad as $quadrad)
{
    echo "Synching Quadrad: {$quadrad['groupTitle']}<br />";

    $vars = array(':groupID' => $quadrad['groupID'],
            ':quadrad' => $quadrad['groupTitle'], );

    $db->prepared_query('INSERT INTO groups (groupID, parentGroupID, name)
                            VALUES (:groupID, -1, :quadrad)
                            ON DUPLICATE KEY UPDATE name=:quadrad', $vars);

    $leaderGroupID = $group->getGroupLeader($quadrad['groupID']);

    $resEmp = $position->getEmployees($leaderGroupID);
    $resEmp = array_merge($resEmp, $group->listGroupEmployees($quadrad['groupID']));
    foreach ($resEmp as $emp)
    {
        if ($emp['userName'] != '')
        {
            $vars = array(':userID' => $emp['userName'],
                          ':groupID' => $quadrad['groupID'], );

            $db->prepared_query('INSERT INTO users (userID, groupID)
                                    VALUES (:userID, :groupID)', $vars);

            // include the backups of employees
            $backups = $employee->getBackups($emp['empUID']);
            foreach ($backups as $backup)
            {
                $vars = array(':userID' => $backup['userName'],
                              ':groupID' => $quadrad['groupID'], );

                $db->prepared_query('INSERT INTO users (userID, groupID)
                                   		 VALUES (:userID, :groupID)', $vars);
            }
        }
    }
}

$vars = array();
$db->prepared_query('DELETE FROM services WHERE serviceID > 0', array());
$db->prepared_query('DELETE FROM service_chiefs WHERE serviceID > 0 AND locallyManaged != 1', array());
// import services
foreach ($res as $service)
{
    $quadID = null;
    $leader = $position->findRootPositionByGroupTag($group->getGroupLeader($service['groupID']), $tag->getParent('service'));
    if (!is_array($leader))
    {
        return 'invalid service';
    }
    $quadID = $leader[0]['groupID'];

    echo "Synching Service: {$service['groupTitle']}<br />";
    $abbrService = isset($service['groupAbbreviation']) ? $service['groupAbbreviation'] : '';
    $vars = array(':serviceID' => $service['groupID'],
                  ':service' => $service['groupTitle'],
                  ':abbrService' => $abbrService,
                  ':groupID' => $quadID, );

    $db->prepared_query('INSERT INTO services (serviceID, service, abbreviatedService, groupID)
                            VALUES (:serviceID, :service, :abbrService, :groupID)
    						ON DUPLICATE KEY UPDATE service=:service, groupID=:groupID', $vars);

    $leaderGroupID = $group->getGroupLeader($service['groupID']);
    $resEmp = $position->getEmployees($leaderGroupID);
//    $resEmp = array_merge($resEmp, $group->listGroupEmployees($service['groupID']));
    foreach ($resEmp as $emp)
    {
        if ($emp['userName'] != '')
        {
            $vars = array(':userID' => $emp['userName'],
                          ':serviceID' => $service['groupID'], );

            $db->prepared_query('INSERT INTO service_chiefs (serviceID, userID)
                                    VALUES (:serviceID, :userID)', $vars);

            // include the backups of employees
            $backups = $employee->getBackups($emp['empUID']);
            foreach ($backups as $backup)
            {
                $vars = array(':userID' => $backup['userName'],
                              ':serviceID' => $service['groupID'], );

                $db->prepared_query('INSERT INTO service_chiefs (serviceID, userID)
                                    VALUES (:serviceID, :userID)', $vars);
            }
        }
    }

    // check if this service is also an ELT
    // if so, update groups table
    if ($service['groupID'] == $quadID)
    {
        $vars = array(':groupID' => $service['groupID']);

        $db->prepared_query('DELETE FROM users WHERE groupID=:groupID', $vars);

        $resChief = $db->prepared_query('SELECT * FROM service_chiefs
    											WHERE serviceID=:groupID
    												AND active=1', $vars);
        foreach ($resChief as $chief)
        {
            $vars = array(':userID' => $chief['userID'],
                          ':groupID' => $quadID, );
            $db->prepared_query('INSERT INTO users (userID, groupID)
                                   		 VALUES (:userID, :groupID)', $vars);
        }
    }
}

// import other groups
foreach (Config::$orgchartImportTags as $tag)
{
    $res = $group->listGroupsByTag($tag);

    foreach ($res as $tgroup)
    {
        echo "Synching Group: {$tgroup['groupTitle']}<br />";

        $vars = array(':groupID' => $tgroup['groupID'],
                ':title' => $tgroup['groupTitle'], );

        $db->prepared_query('INSERT INTO groups (groupID, parentGroupID, name)
                            VALUES (:groupID, NULL, :title)
                            ON DUPLICATE KEY UPDATE name=:title', $vars);

        $positions = $group->listGroupPositions($tgroup['groupID']);
        $resEmp = $group->listGroupEmployees($tgroup['groupID']);
        foreach ($positions as $tposition)
        {
            $resEmp = array_merge($resEmp, $position->getEmployees($tposition['positionID']));
        }
        foreach ($resEmp as $emp)
        {
            if ($emp['userName'] != '')
            {
                $vars = array(':userID' => $emp['userName'],
                              ':groupID' => $tgroup['groupID'], );

                $db->prepared_query('INSERT INTO users (userID, groupID)
										VALUES (:userID, :groupID)', $vars);

                // include the backups of employees
                $backups = $employee->getBackups($emp['empUID']);
                foreach ($backups as $backup)
                {
                    $vars = array(':userID' => $backup['userName'],
                                  ':groupID' => $tgroup['groupID'], );

                    $db->prepared_query('INSERT INTO users (userID, groupID)
										VALUES (:userID, :groupID)', $vars);
                }
            }
        }
    }
}

$groupIDs = $db->query('SELECT category_privs.groupID
                        FROM category_privs
                        LEFT JOIN groups USING (groupID)
                        WHERE groups.groupID IS NULL;');
foreach($groupIDs as $groupIDToDelete)
{

    $db->prepared_query('DELETE FROM category_privs WHERE groupID = :groupID', array(':groupID' => $groupIDToDelete['groupID']));
}

$db->commitTransaction();

echo '<br />... Done.';
