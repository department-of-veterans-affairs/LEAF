<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class FTEdataController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $form;

    private $db;

    public function __construct($db, $login)
    {
        $this->form = new Form($db, $login);
        $this->db = $db;
    }

    public function get($act)
    {
        $form = $this->form;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('FTEdata/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('FTEdata/selecteeSheet', function () {
            $list = explode(',', $_GET['recordIDs']);
            $recordIDs = '';
            foreach ($list as $id)
            {
                if (is_numeric($id))
                {
                    $recordIDs .= "{$id},";
                }
            }
            $recordIDs = trim($recordIDs, ',');

            $res = $this->db->prepared_query("SELECT * FROM records
                               		RIGHT JOIN (SELECT * FROM category_count
                                                    WHERE categoryID='fte'
                                                AND count > 0) j4 USING (recordID)
                                    RIGHT JOIN (SELECT *, time as dirApprovalTime FROM records_dependencies
                                                    WHERE dependencyID = 3
                                                        AND filled = 1
                                                ) rj1
                                                USING (recordID)
                                    LEFT JOIN services USING (serviceID)
                                    WHERE records.deleted = 0
                                        AND records.submitted != 0
        								AND recordID in ({$recordIDs})", array());

            $data = array();
            foreach ($res as $result)
            {
                $data[$result['recordID']] = $result;
            }

            $raw = $this->form->getCustomData($data, '5,6,7,230,250,251,252,253,254,255,256,257,157,293,294,299,300,320,328,263,335,354,355,356,360,364,365,366,367');

            $formattedData = array();
            foreach ($raw as $item)
            {
                $numberOfPeople = isset($item['s1']['id356']) ? $item['s1']['id356'] : 1;
                for ($i = 0; $i < $numberOfPeople; $i++)
                {
                    $j = $i + 1;
                    $temp = $item;
                    $temp['displayedRecordID'] = "{$item['recordID']}.{$j}";
                    $temp = array_merge($temp, $item["s$j"]);
                    $temp['id7'] = $item['s1']['id7'];	// position title
                    $temp['id5'] = $item['s1']['id5'];	// vice
                    $temp['id6'] = $item['s1']['id6'];	// status
                    $temp['id300'] = $item['s1']['id300'];	// internal/external
                    $temp['id335'] = $item['s1']['id335'];	// non-mc funded
                    $temp['id256'] = $item['s1']['id256'];	// hr specialist
                    $temp['calculatedNumFTE'] = $numberOfPeople >= 1 ? $temp['s1']['id230'] / $numberOfPeople : $temp['s1']['id230'];
                    $formattedData[] = $temp;
                }
            }

            return $formattedData;
        });

        $this->index['GET']->register('FTEdata/selecteeSheetDateRange', function () {
            if (!$this->isDate($_GET['startDate']) && !$this->isDate($_GET['endDate']))
            {
                return 'Invalid Date';
            }

            $startDate = (int)strtotime($_GET['startDate']);
            $endDate = (int)strtotime($_GET['endDate']);
            $vars = array("startDate" => $startDate, "endDate" => $endDate);
            $res = $this->db->prepared_query("SELECT * FROM records
                               		RIGHT JOIN (SELECT * FROM category_count
                                                    WHERE categoryID='fte'
                                                AND count > 0) j4 USING (recordID)
                                    RIGHT JOIN (SELECT *, time as dirApprovalTime FROM records_dependencies
                                                    WHERE dependencyID = 3
                                                        AND filled = 1
        												AND time >= :startDate
        												AND time <= :endDate
                                                ) rj1
                                                USING (recordID)
                                    LEFT JOIN services USING (serviceID)
                                    WHERE records.deleted = 0
                                        AND records.submitted != 0", $vars);

            $data = array();
            foreach ($res as $result)
            {
                $data[$result['recordID']] = $result;
            }

            $raw = $this->form->getCustomData($data, '5,6,7,230,250,251,252,253,254,255,256,257,157,293,294,299,300,320,328,263,335,354,355,356,360,364,365,366,367');

            $formattedData = array();
            foreach ($raw as $item)
            {
                $numberOfPeople = isset($item['s1']['id356']) ? $item['s1']['id356'] : 1;
                for ($i = 0; $i < $numberOfPeople; $i++)
                {
                    $j = $i + 1;
                    $temp = $item;
                    $temp['displayedRecordID'] = "{$item['recordID']}.{$j}";
                    $temp = isset($item["s$j"]) ? array_merge($temp, $item["s$j"]) : $temp;
                    $temp['id7'] = $item['s1']['id7'];	// position title
                    $temp['id5'] = $item['s1']['id5'];	// vice
                    $temp['id6'] = $item['s1']['id6'];	// status
                    $temp['id300'] = $item['s1']['id300'];	// internal/external
                    $temp['id335'] = $item['s1']['id335'];	// non-mc funded
                    $temp['id256'] = $item['s1']['id256'];	// hr specialist
                    $temp['calculatedNumFTE'] = $numberOfPeople >= 1 ? $item['s1']['id230'] / $numberOfPeople : $temp['s1']['id230'];
                    $formattedData[] = $temp;
                }
            }

            return $formattedData;
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }

    private function isDate($value)
    {
        if (!$value)
        {
            return false;
        }

        try
        {
            new \DateTime($value);

            return true;
        }
        catch (\Exception $e)
        {
            return false;
        }
    }
}
