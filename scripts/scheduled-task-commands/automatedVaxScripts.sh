#!/bin/bash
php /var/www/html/NATIONAL/101/vaccination_data_reporting/scripts/exportVaccineInfoDaily.php
php /var/www/html/NATIONAL/101/vaccination_data_reporting/scripts/importVaccineInfoDaily.php
php /var/www/html/NATIONAL/101/vaccination_data_reporting/scripts/getCompAuditInfoNoEmail.php
php /var/www/html/NATIONAL/101/supervisor_reporting/scripts/getPaperCompAuditInfo.php
php /var/www/html/NATIONAL/101/vaccination_data_reporting/scripts/updateExemptStatusNoEmail.php