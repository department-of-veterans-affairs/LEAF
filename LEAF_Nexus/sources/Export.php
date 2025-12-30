<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    This is an implementation of exportPDL.php, designed to work with the existing API handling system.

*/

namespace Orgchart;

use App\Leaf\Db;

class Export
{
    protected $db;
    protected $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    // Contents primarily copied from exportPDL.php
    public function exportPDL() : array {
        $position = new Position($this->db, $this->login);
        $tag = new Tag($this->db, $this->login);

        //echo "LEAF Position ID, HR Smart Position Number, Service, Position Title, Classification Title, Employee Name, Employee Username, Supervisor Name, Pay Plan, Series, Pay Grade, FTE Ceiling / Total Headcount, Current FTE, PD Number, Note\r\n";

        $res = $this->db->prepared_query('SELECT * FROM positions', array());

        $output = array(); // old output structure
        $apiOut = array(); // new output structure

        //$pos = $res[15]; // for testing
        foreach ($res as $pos)
        {
            $data = $position->getAllData($pos['positionID']);
            $output[$pos['positionID']]['employeees'] = $position->getEmployees($pos['positionID']);

            $serviceChief = $position->findRootPositionByGroupTag($pos['positionID'], 'service');

            $output[$pos['positionID']]['positionTitle'] = $pos['positionTitle'];
            $positionService = $position->getService($pos['positionID']);
            $output[$pos['positionID']]['service'] = isset($positionService[0]) ? $positionService[0]['groupTitle'] : '';
            // If the position is a service chief, show the ELT's Service
            if (isset($serviceChief[0])
                && $serviceChief[0]['positionID'] == $pos['positionID'])
            {
                $elt = $position->findRootPositionByGroupTag($pos['positionID'], $tag->getParent('service'));
                $output[$pos['positionID']]['service'] = $elt[0]['groupTitle'];
                // If position is an ELT member, show their supervisor's service (director)
                if ($serviceChief[0]['groupID'] == $elt[0]['groupID'])
                {
                    $super = $position->getSupervisor($pos['positionID']);
                    if (isset($super[0]))
                    {
                        $superService = $position->getService($super[0]['positionID']);
                        if(isset($superService[0]))
                        {
                            $output[$pos['positionID']]['service'] = $superService[0]['groupTitle'];
                        }
                    }
                }
            }

            $output[$pos['positionID']]['data']['Classification Title'] = $data[12]['data'];
            $output[$pos['positionID']]['data']['Pay Plan'] = $data[2]['data'];
            $output[$pos['positionID']]['data']['Series'] = $data[13]['data'];
            $output[$pos['positionID']]['data']['Pay Grade'] = $data[14]['data'];
            //	$output[$pos['positionID']]['data']['FTE Ceiling'] = ($data[11]['data'] / count($output[$pos['positionID']]['employeees']));
            //	$output[$pos['positionID']]['data']['Current FTE'] = ($data[17]['data'] / count($output[$pos['positionID']]['employeees']));
            $output[$pos['positionID']]['data']['FTE'] = 0;
            if (is_numeric($data[11]['data'])
                && is_numeric($data[19]['data']))
            {
                $output[$pos['positionID']]['data']['FTE'] = $data[19]['data'] == 0 ? 0 : round($data[11]['data'] / $data[19]['data'], 5);
            }
            $output[$pos['positionID']]['data']['Current FTE'] = $data[17]['data'];
            $output[$pos['positionID']]['data']['PD Number'] = $data[9]['data'];
            $output[$pos['positionID']]['data']['HR Smart Position #'] = $data[26]['data'];

            foreach ($output[$pos['positionID']]['employeees'] as $emp)
            {
                // find supervisor
                $supervisor = $position->getSupervisor($pos['positionID']);
                $supervisorName = '';
                if (isset($supervisor[0]['lastName'])
                    && $supervisor[0]['isActing'] == 0)
                {
                    $supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
                }
      
                $employeeName = '';
                if($emp['lastName'] != ''
                    && $emp['isActing'] == 0) {
                    $employeeName = $emp['lastName'] . ', ' . $emp['firstName'];
                }
                $apiOut[] = [
                    'LEAF Position ID' => $pos['positionID'],
                    'HR Smart Position Number' => $output[$pos['positionID']]['data']['HR Smart Position #'],
                    'Service' => $output[$pos['positionID']]['service'],
                    'Position Title' => $output[$pos['positionID']]['positionTitle'],
                    'Classification Title' => $output[$pos['positionID']]['data']['Classification Title'],
                    'Employee Name' => $employeeName,
                    'Employee Username' => $emp['userName'],
                    'Supervisor Name' => $supervisorName,
                    'Pay Plan' => $output[$pos['positionID']]['data']['Pay Plan'],
                    'Series' => $output[$pos['positionID']]['data']['Series'],
                    'Pay Grade' => $output[$pos['positionID']]['data']['Pay Grade'],
                    'FTE Ceiling / Total Headcount' => $output[$pos['positionID']]['data']['FTE'],
                    'Current FTE' => $output[$pos['positionID']]['data']['Current FTE'],
                    'PD Number' => $output[$pos['positionID']]['data']['PD Number'],
                    'Note' => $data[19]['data'] == 0 ? 'Missing Total Headcount' : '',
                ];
            }
            if (count($output[$pos['positionID']]['employeees']) < $data[19]['data'])
            {
                $vacancies = $data[19]['data'] - count($output[$pos['positionID']]['employeees']);
                for ($i = 0; $i < $vacancies; $i++)
                {
                    // find supervisor
                    $supervisor = $position->getSupervisor($pos['positionID']);
                    $supervisorName = '';
                    if (isset($supervisor[0]['lastName'])
                        && $supervisor[0]['isActing'] == 0)
                    {
                        $supervisorName = "{$supervisor[0]['lastName']}, {$supervisor[0]['firstName']}";
                    }

                    $apiOut[] = [
                        'LEAF Position ID' => $pos['positionID'],
                        'HR Smart Position Number' => $output[$pos['positionID']]['data']['HR Smart Position #'],
                        'Service' => $output[$pos['positionID']]['service'],
                        'Position Title' => $output[$pos['positionID']]['positionTitle'],
                        'Classification Title' => $output[$pos['positionID']]['data']['Classification Title'],
                        'Employee Name' => '',
                        'Employee Username' => '',
                        'Supervisor Name' => $supervisorName,
                        'Pay Plan' => $output[$pos['positionID']]['data']['Pay Plan'],
                        'Series' => $output[$pos['positionID']]['data']['Series'],
                        'Pay Grade' => $output[$pos['positionID']]['data']['Pay Grade'],
                        'FTE Ceiling / Total Headcount' => $output[$pos['positionID']]['data']['FTE'],
                        'Current FTE' => $output[$pos['positionID']]['data']['Current FTE'],
                        'PD Number' => $output[$pos['positionID']]['data']['PD Number'],
                        'Note' => $data[19]['data'] == 0 ? 'Missing Total Headcount' : '',
                    ];
                }
            }
        }

        return $apiOut;
    }
}