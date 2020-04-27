<?php

/*
    Prepend script for enabling coverage tracing during automated test execution.
    This script has been configured with the php_flag auto_prepend_file.

    The script initializes a coverage during for every file requested.


*/

if ("cli" == php_sapi_name()) { // TODO; also abort if XDEBUG_PROFILE is not found in request
    return;
}


/**
 * Call back is registered to finish generating code coverage
 *
 * @param CodeCoverage $coverage Code coverage parameter
 * @return void
 */
function shutdown($coverage)
{
    // This is our shutdown function, in
    // here we can do any last operations
    // before the script is complete.

    $coverage->stop();

    $cov = '<?php return unserialize(' . var_export(serialize($coverage), true) . ');';
    $str = rand();
    $result = md5($str);
    file_put_contents('/var/www/html/test/cov/site.' . date('U') . $result . '.cov', $cov);
    error_log('Saving code coverage file');
}

require_once __DIR__ . '/vendor/autoload.php';
use SebastianBergmann\CodeCoverage\CodeCoverage;

$coverage = new CodeCoverage;
register_shutdown_function('shutdown', $coverage);

$coverage->filter()->addDirectoryToWhitelist('/var/www/html/LEAF_Nexus/');
$coverage->filter()->addDirectoryToWhitelist('/var/www/html/LEAF_Request_Portal/');
$coverage->start('Site coverage');

error_log('Initializing code coverage scan');

