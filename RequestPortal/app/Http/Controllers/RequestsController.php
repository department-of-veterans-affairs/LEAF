<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use LEAF\CommonConfig;
use RequestPortal\Data\Model\Record;
use RequestPortal\Data\Repositories\Contracts\FormsRepository;
use RequestPortal\Data\Repositories\Contracts\RecordsRepository;
use RequestPortal\Data\Repositories\Contracts\PortalUsersRepository;
// use RP\Form;
// use RP\Db\Config;
// use RP\Db\DB as RPDB;
// use RP\Db\DB_Config;
// use RP\Login as RPLogin;
use RequestPortal\Data\Repositories\Contracts\ServiceRepository;
//TODO replace all login functions
class RequestsController extends Controller
{
    /**
     * Records Repository
     *
     * @var RecordsRepository
     */
    protected $records;

    /**
     * Service Repository
     *
     * @var ServiceRepository
     */
    protected $services;

    /**
     * Forms Repository
     *
     * @var FormsRepository
     */
    protected $forms;

    /**
     * Protal Users Repository
     *
     * @var PortalUsersRepository
     */
    protected $portalUsers;

    protected $oldForm;

    private $cache = array();

    public function __construct(RecordsRepository $records, ServiceRepository $services, FormsRepository $forms, PortalUsersRepository $portalUsers)
    {
        $this->middleware(array('IsAuth', 'GetDatabaseName'));
        $this->records = $records;
        $this->services = $services;
        $this->forms = $forms;
        $this->portalUsers = $portalUsers;
        
        // $db_config = new DB_Config();
        // $config = new Config();
        // $db = new RPDB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
        // $db_phonebook = new RPDB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        // $login = new RPLogin($db_phonebook, $db);

        // $this->oldForm = new Form($db, $login);
    }

    public function isCategory($categoryID)
    {
        if (isset($this->cache['isCategory_' . $categoryID]))
        {
            return $this->cache['isCategory_' . $categoryID];
        }

        $res = $this->forms->getCountById($categoryID);

        if ($res != 0)
        {
            $this->cache['isCategory_' . $categoryID] = 1;

            return true;
        }

        $this->cache['isCategory_' . $categoryID] = 0;

        return false;
    }

    public function getAll(Request $request, $route)
    {
        return view('records', array(
            'records' => $this->records->getAll(),
            'visn' => $route,
        ));
    }

    public function getById($route, $recordID)
    {
        return view('records', array(
            'records' => $this->records->getById($recordID),
            'visn' => $route,
        ));
    }

    public function create($route)
    {
        return view('newrecord', array('visn' => $route));
    }

    /**
     * Store a newly created request
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request, $route)
    {
        $title = $request->filled('title') ? $request->title : '[blank]';
        $service = $request->filled('service') ? (int)$request->service : 0;
        $priority = $request->filled('priority') ? (int)$request->priority : 0;

        $keys = $request->input();

        $countCategories = 0;
        foreach (array_keys($keys) as $key)
        {
            if (strpos($key, 'num') === 0)
            {
                $countCategories++;
            }
        }

        if ($countCategories == 0)
        {
            // TODO: redirect to error page saying "Error: No forms selected. Please Select a form and try again."
            return redirect('/welcome');
        }

        $res = $this->services->getById($service);
        $serviceID = $res != null ? $res->serviceID : null;

        if (!is_numeric($serviceID))
        {
            if ($service == 0)
            {
                $serviceID = 0;
            }
            else
            {
                // TODO: redirect to error page saying "Error: Service ID is not synchronized to Org. Chart."
                return redirect('/welcome');
            }
        }

        $record = new Record(time(), $serviceID, session('userID'), $title, $priority);
        $recordID = $this->records->create($record);

        if ($recordID == null)
        {
            return false;
        }

        foreach (array_keys($keys) as $key)
        {
            if (strpos($key, 'num') === 0)
            {
                // Check how many copies of the form are needed
                $tCount = is_numeric($keys[$key]) ? $keys[$key] : 1;

                if ($tCount >= 1)
                {
                    $categoryID = strtolower(substr($key, 3));

                    if ($this->isCategory($categoryID))
                    {
                        $this->forms->createFormCount($recordID, $categoryID, $tCount);

                        $res = $this->forms->getStapledForms($categoryID);

                        foreach ($res as $merged)
                        {
                            $this->forms->createFormCount($recordID, $merged->stapledCategoryID, $tCount);
                        }
                    }
                }
            }
        }

        return redirect()->route('request.detail', array(
            'visn' => $route, 'requestId' => $recordID,
        ));
    }

    public function updateIndicator(Request $request, $route, $recordID, $indicatorId)
    {
        // series will always be 1 (for now)
        $series = 1;

        if ($request->uploads)
        {
            $commonConfig = new CommonConfig();
            $fileExtensionWhitelist = $commonConfig->requestWhitelist;

            $files = $request->uploads;
            foreach ($files as $file)
            {
                echo $file->extension();
            }
        }

        return 0;
    }

    public function delete($route, $recordID)
    {
        return $this->records->delete($recordID);
    }

    public function restore($route, $recordID)
    {
        // only allow admins to un-delete records
        if (!$this->portalUsers->isAdmin(session('userID')))
        {
            return 0;
        }
        return $this->records->restore($recordID);
    }

    /**
     * Scrubs a list of records to remove records that the current user doesn't have access to
     * Defaults to enable read access, unless needToKnow mode is set for any form
     * @param array
     * @return array Returns the input array, scrubbing records that the current user doesn't have access to
     * 
     * //todo cacheing
     */
    public function checkReadAccess($records)
    {
        if (count($records) == 0)
        {
            return $records;
        }

        $recordIDs = '';
        foreach ($records as $item)
        {
            if (is_numeric($item['recordID']))
            {
                $recordIDs .= $item['recordID'] . ',';
            }
        }
        $recordIDs = trim($recordIDs, ',');
        $recordIDsHash = sha1($recordIDs);

        $res = array();
        $hasCategoryAccess = array(); // the keys will be categoryIDs that the current user has access to
        if (isset($this->cache["checkReadAccess_{$recordIDsHash}"]))
        {
            $res = $this->cache["checkReadAccess_{$recordIDsHash}"];
        }
        else
        {
            // get a list of records which have categories marked as need-to-know
            $res = $this->getConn('category_count')
            ->select('records.recordID', 'categories.categoryID', 'step_dependencies.dependencyID', 'groupID', 'serviceID', 'indicatorID_for_assigned_empUID', 'indicatorID_for_assigned_groupID')
            ->leftJoin('category_count', 'records.recordID', '=', 'category_count.recordID')
            ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
            ->leftJoin('workflows', 'categories.workflowID', '=', 'workflows.workflowID')
            ->leftJoin('workflow_steps', 'workflows.workflowID', '=', 'workflow_steps.workflowID')
            ->leftJoin('step_dependencies', 'workflow_steps.stepID', '=', 'step_dependencies.stepID')
            ->leftJoin('dependency_privs', 'step_dependencies.dependencyID', '=', 'dependency_privs.dependencyID')
            ->where([['needToKnow', 1],['count', '>', 0]])
            ->whereIn('records.recordID', explode(',', $recordIDs))
            ->get()
            ->toArray();

            // if a needToKnow form doesn't have a workflow (eg: general info), pull in approval chain for associated forms
            $t_needToKnowRecords = '';
            $t_uniqueCategories = array();
            foreach ($res as $dep)
            {
                $dep = (array) $dep;
                if ($dep['dependencyID'] == null)
                {
                    if (is_numeric($dep['recordID']))
                    {
                        $t_needToKnowRecords .= $dep['recordID'] . ',';
                    }
                }

                // keep track of unique categories
                if (isset($dep['categoryID']) && !isset($t_uniqueCategories[$dep['categoryID']]))
                {
                    $t_uniqueCategories[$dep['categoryID']] = 1;
                }
            }

            $t_needToKnowRecords = trim($t_needToKnowRecords, ',');
            if ($t_needToKnowRecords != '')
            {
                $res2 = $this->getConn('category_count')
                ->select('records.recordID', 'step_dependencies.dependencyID', 'groupID', 'serviceID', 'indicatorID_for_assigned_empUID', 'indicatorID_for_assigned_groupID')
                ->leftJoin('category_count', 'records.recordID', '=', 'category_count.recordID')
                ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
                ->leftJoin('workflows', 'categories.workflowID', '=', 'workflows.workflowID')
                ->leftJoin('workflow_steps', 'workflows.workflowID', '=', 'workflow_steps.workflowID')
                ->leftJoin('step_dependencies', 'workflow_steps.stepID', '=', 'step_dependencies.stepID')
                ->leftJoin('dependency_privs', 'step_dependencies.dependencyID', '=', 'dependency_privs.dependencyID')
                ->where([['needToKnow', 0],['count', '>', 0]])
                ->whereIn('records.recordID', explode(',', $t_needToKnowRecords))
                ->get()
                ->toArray();       

                $res = array_merge($res, $res2);
            }
            
            // find out if "collaborator access" is being used for any categoryID in the set
            // and whether the current user has access
            $uniqueCategoryIDs = array_keys($t_uniqueCategories);
            $catsInGroups = $this->getConnForTable('category_privs')
                ->where('readable', 1)
                ->whereIn('categoryID', $uniqueCategoryIDs)
                ->get()
                ->toArray(); 
            if (count($catsInGroups) > 0)
            {
                $groups = $this->portalUsers->getMembership();
                foreach ($catsInGroups as $cat)
                {
                    $cat = (array) $cat;
                    if (isset($groups['groupID'][$cat['groupID']])
                        && $groups['groupID'][$cat['groupID']] == 1)
                    {
                        $hasCategoryAccess[$cat['categoryID']] = 1;
                    }
                }
            }

            $this->cache["checkReadAccess_{$recordIDsHash}"] = $res;
        }

        // don't scrub anything if no limits are in place
        if (count($res) == 0)
        {
            return $records;
        }

        // admin group
        if ($this->portalUsers->isAdmin())
        {
            return $records;
        }

        $temp = isset($this->cache['checkReadAccess_tempArray']) ? $this->cache['checkReadAccess_tempArray'] : array();

        // grant access
        foreach ($res as $dep)
        {
            if (!isset($temp[$dep['recordID']]) || $temp[$dep['recordID']] == 0)
            {
                $temp[$dep['recordID']] = 0;

                $temp[$dep['recordID']] = $this->hasDependencyAccess($dep['dependencyID'], $dep) ? 1 : 0;

                // request initiator
                if ($dep['empUID'] == $this->login->getEmpUID())
                {
                    $temp[$dep['recordID']] = 1;
                }

                // collaborator access
                if (isset($hasCategoryAccess[$dep['categoryID']]))
                {
                    $temp[$dep['recordID']] = 1;
                }
            }
        }
        $this->cache['checkReadAccess_tempArray'] = $temp;

        foreach ($records as $record)
        {
            if (isset($temp[$record['recordID']]) && $temp[$record['recordID']] == 0)
            {
                unset($records[$record['recordID']]);
            }
        }

        return $records;
    }

        /**
     * Checks if the current user has access to a particular dependency
     * @param dependencyID
     * @param details - Associative Array containing dependency-specific details, eg: $details['groupID']
     * @return boolean
     * 
     * TODO ALL this
     */
    public function hasDependencyAccess($dependencyID, $details)
    {
        switch ($dependencyID) {
            case 1:
                if ($this->login->checkService($details['serviceID']))
                {
                    return true;
                }

                break;
            case 8:
                $quadGroupIDs = $this->login->getQuadradGroupID();
                $res3 = array();
                if ($quadGroupIDs != 0)
                {
                    if (isset($this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']]))
                    {
                        $res3 = $this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']];
                    }
                    else
                    {
                        $vars3 = array(':serviceID' => (int)$details['serviceID']);
                        $res3 = $this->db->prepared_query("SELECT * FROM services
    							WHERE groupID IN ($quadGroupIDs)
    							AND serviceID=:serviceID", $vars3);
                        $this->cache['checkReadAccess_quadGroupIDs_' . $quadGroupIDs . '_' . $details['serviceID']] = $res3;
                    }
                }

                if (isset($res3[0]))
                {
                    return true;
                }

                break;
            case -1: // dependencyID -1 : person designated by the requestor
                $empUID = 0;
                if (isset($this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']]))
                {
                    $empUID = $this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']];
                }
                else
                {
                    $vars = array(':indicatorID' => (int)$details['indicatorID_for_assigned_empUID'],
                            ':recordID' => (int)$details['recordID'], );
                    $resEmpUID = $this->db->prepared_query('SELECT * FROM data
                                                                        WHERE recordID=:recordID
                                                                            AND indicatorID=:indicatorID
                                                                            AND series=1', $vars);
                    if (isset($resEmpUID[0]))
                    {
                        $empUID = $resEmpUID[0]['data'];
                        $this->cache['checkReadAccess_assigned_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_empUID']] = $empUID;
                    }
                }

                //check if the requester has any backups
                $nexusDB = $this->login->getNexusDB();
                $vars4 = array(':empId' => XSSHelpers::xscrub($empUID));
                $backupIds = $nexusDB->prepared_query('SELECT * FROM relation_employee_backup WHERE empUID =:empId', $vars4);

                if ($empUID == $this->login->getEmpUID())
                {
                    return true;
                }
                    //check and provide access to backups
                    foreach ($backupIds as $row)
                    {
                        if ($row['backupEmpUID'] == $this->login->getEmpUID())
                        {
                            return true;
                        }
                    }

                break;
            case -2: // dependencyID -2 : requestor followup
                $varsPerson = array(':recordID' => (int)$details['recordID']);
                $resPerson = $this->db->prepared_query('SELECT empUID FROM records
               												WHERE recordID=:recordID', $varsPerson);

                if ($resPerson[0]['empUID'] == $this->login->getEmpUID())
                {
                    return true;
                }

                break;
            case -3: // dependencyID -3 : group designated by the requestor
                $groupID = 0;
                if (isset($this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']]))
                {
                    $groupID = $this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']];
                }
                else
                {
                    $vars = array(':indicatorID' => (int)$details['indicatorID_for_assigned_groupID'],
                                  ':recordID' => (int)$details['recordID'], );
                    $resGroupID = $this->db->prepared_query('SELECT * FROM data
                                                                       WHERE recordID=:recordID
                                                                           AND indicatorID=:indicatorID
                                                                           AND series=1', $vars);
                    if (isset($resGroupID[0]))
                    {
                        $groupID = $resGroupID[0]['data'];
                        $this->cache['checkReadAccess_assigned_group_indicatorID_' . $details['recordID'] . '_' . $details['indicatorID_for_assigned_groupID']] = $groupID;
                    }
                }

                if ($this->login->checkGroup($groupID))
                {
                    return true;
                }

                break;
            default:
                if ($this->login->checkGroup($details['groupID']))
                {
                    return true;
                }

                break;
        }

        return false;
    }

    public function getForm($route, $recordID)
    {
        if ($this->records->isNeedToKnow($recordID))
        {
            $records[$recordID]['recordID'] = $recordID;
            $resRead = $this->checkReadAccess($records);
            if (!isset($resRead[$recordID]))
            {
                return '';
            }
            else
            {
                return $this->records->getForm($recordID);
            }
        }
    }

    public function getFormJSON($route, $recordID)
    {
        if ($this->records->isNeedToKnow($recordID))
        {
            $records[$recordID]['recordID'] = $recordID;
            $resRead = $this->checkReadAccess($records);
            if (!isset($resRead[$recordID]))
            {
                return '';
            }
            else
            {
                return $this->records->getFormJSON($recordID);
            }
        }
    }

    public function debug($route)
    {
        return $this->checkReadAccess([['recordID'=>17]]);
    }
}
