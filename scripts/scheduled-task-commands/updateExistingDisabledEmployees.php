<?php
require_once 'globals.php';
require_once APP_PATH . '/Leaf/Db.php';

$VISNS = array('acc.dva.va.gov',
                'cem.va.gov',
                'dva.va.gov',
                'mpi.v21.med.va.gov',
                'r01.med.va.gov',
                'r02.med.va.gov',
                'r03.med.va.gov',
                'r04.med.va.gov',
                'va',
                'va.gov',
                'vba.va.gov',
                'vha.med.va.gov',
                'VHA01',
                'VHA02',
                'VHA03',
                'VHA04',
                'VHA05',
                'VHA06',
                'VHA07',
                'VHA08',
                'VHA09',
                'VHA10',
                'VHA11',
                'VHA12',
                'VHA15',
                'VHA16',
                'VHA17',
                'VHA18',
                'VHA19',
                'VHA20',
                'VHA21',
                'VHA22',
                'VHA23',
);

function updateEmps($VISNS) {
    foreach ($VISNS as $visn) {
        if (str_starts_with($visn['data'], 'DN,')) {
            exec("php /var/www/scripts/updateExistingDisabledNationalOrgchart.php {$visn} > /dev/null 2>/dev/null &");
            echo "Deploying to: {$visn}\r\n";
        }
    }
}

updateEmps($VISNS);