<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Index for simple, non-security sensitive responses
    Date Created: June 6, 2011

*/

error_reporting(E_ERROR);

require_once getenv('APP_LIBS_PATH') . '/loaders/Leaf_autoloader.php';

$action = isset($_GET['a']) ? $_GET['a'] : '';

switch ($action) {
    // Get the timestamp of the last action
    case 'lastaction':
        if (!isset($_GET['recordID']))
        {
            $res = DB->prepared_query('SELECT time FROM action_history
        							ORDER BY time DESC
        							LIMIT 1', array());
            echo isset($res[0]['time']) ? $res[0]['time'] : 0;
        }
        else
        {
            $vars = array('recordID' => $_GET['recordID']);
            $res = DB->prepared_query('SELECT time FROM action_history
                    						WHERE recordID = :recordID
                							ORDER BY time DESC
                							LIMIT 1', $vars);
            echo isset($res[0]['time']) ? $res[0]['time'] : 0;
        }

        break;
    default:
        break;
}
