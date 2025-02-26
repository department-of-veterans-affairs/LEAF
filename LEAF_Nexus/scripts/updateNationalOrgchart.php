<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Refreshes employee data into local orgchart
*/

passthru('php /var/www/scripts/scheduled-task-commands/updateNationalOrgchartEmployees.php');
passthru('php /var/www/scripts/scheduled-task-commands/disableNationalOrgchartEmployees.php');
