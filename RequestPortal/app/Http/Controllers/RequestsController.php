<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use LEAF\CommonConfig;
use LEAF\XSSHelpers;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;
use RequestPortal\Data\Model\Record;
use RequestPortal\Data\Repositories\Contracts\FormsRepository;
use RequestPortal\Data\Repositories\Contracts\RecordsRepository;
use RequestPortal\Data\Repositories\Contracts\PortalUsersRepository;
use RequestPortal\Data\Repositories\Contracts\ServiceRepository;
use RequestPortal\Data\Repositories\Contracts\ActionHistoryRepository;
use Nexus\Data\Repositories\Contracts\EmployeesRepository;
use Nexus\Data\Repositories\Contracts\PositionsRepository;
use Nexus\Data\Repositories\Contracts\GroupsRepository;

// use RP\Form;
// use RP\Db\Config;
// use RP\Db\DB as RPDB;
// use RP\Db\DB_Config;
// use RP\Login as RPLogin;

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

    /**
     * Action History Repository
     *
     * @var ActionHistoryRepository
     */
    protected $actionHistory;

    /**
     * Nexus/Employees Repository
     *
     * @var EmployeesRepository
     */
    protected $employees;

    /**
     * Nexus/Positions Repository
     *
     * @var PositionsRepository
     */
    protected $positions;

    /**
     * Nexus/Groups Repository
     *
     * @var GroupsRepository
     */
    protected $groups;

    protected $oldForm;

    private $cache = array();

    public function __construct(RecordsRepository $records, 
                                ServiceRepository $services, 
                                FormsRepository $forms, 
                                PortalUsersRepository $portalUsers,
                                ActionHistoryRepository $actionHistory,
                                EmployeesRepository $employees,
                                PositionsRepository $positions,
                                GroupsRepository $groups)
    {
        $this->middleware(array('IsAuth', 'GetDatabaseName'));
        $this->records = $records;
        $this->services = $services;
        $this->forms = $forms;
        $this->portalUsers = $portalUsers;
        $this->actionHistory = $actionHistory;
        $this->employees = $employees;
        $this->positions = $positions;
        $this->groups = $groups;
        
        // $db_config = new DB_Config();
        // $config = new Config();
        // $db = new RPDB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
        // $db_phonebook = new RPDB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        // $login = new RPLogin($db_phonebook, $db);

        // $this->oldForm = new Form($db, $login);
    }

    /**
     * Checks if the current user has read access to a form
     * @param int $recordID
     * @param int $categoryID
     * @param int $indicatorID
     * @return int 1 = has access, 0 = no access
     */
    public function hasReadAccess($recordID)
    {
        if (isset($this->cache["hasReadAccess_{$recordID}"]))
        {
            return $this->cache["hasReadAccess_{$recordID}"];
        }

        if ($this->records->isNeedToKnow($recordID))
        {
            $query[$recordID]['recordID'] = $recordID;
            $resRead = $this->portalUsers->checkReadAccess(session('userID'), $query);
            if (!isset($resRead[$recordID]))
            {
                $this->cache["hasReadAccess_{$recordID}"] = 0;

                return 0;
            }
        }
        $this->cache["hasReadAccess_{$recordID}"] = 1;

        return 1;
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

        $record = new Record(time(), $serviceID, $this->portalUsers->getEmpUID(session('userID')), $title, $priority);
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
            'visn' => $route, 'requestID' => $recordID,
        ));
    }

    public function updateIndicator(Request $request, $recordID, $indicatorID)
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

    public function delete($recordID)
    {
        return $this->records->delete($recordID);
    }

    public function restore($recordID)
    {
        // only allow admins to un-delete records
        if (!$this->portalUsers->isAdmin(session('userID')))
        {
            return 0;
        }
        return $this->records->restore($recordID);
    }



    public function getForm($recordID)
    {
        if ($this->records->isNeedToKnow($recordID))
        {
            $records[$recordID]['recordID'] = $recordID;//new array holding this record's id
            $resRead = $this->portalUsers->checkReadAccess(session('userID'), $records);
            if (!isset($resRead[$recordID]))
            {
                return '';
            }
            
        }
        
        return $this->records->getForm($recordID);
    }

    public function getFormJSON($recordID)
    {
        if ($this->records->isNeedToKnow($recordID))
        {
            $records[$recordID]['recordID'] = $recordID;
            $resRead = $this->portalUsers->checkReadAccess(session('userID'), $records);
            if (!isset($resRead[$recordID]))
            {
                return '';
            }
        }
        
        return $this->records->getFormJSON($recordID);
    }

    public function addToCategoryCount($recordID, $categoryID)
    {
        // only allow admins
        if (!$this->portalUsers->isAdmin(session('userID')) || !$this->isCategory($categoryID))
        {
            return 0;
        }
        else
        {
            $this->records->addToCategoryCount($recordID, $categoryID);
        }
    }

    public function switchCategoryCount(Request $request, $recordID)
    {
        $categories = $request->input('categories');
        // only allow admins
        if (!$this->portalUsers->isAdmin(session('userID')) || !$this->isCategory($categoryID))
        {
            return 0;
        }
        else
        {
            $this->records->switchCategoryCount($recordID);

            foreach ($categories as $category)
            {
                $this->addToCategoryCount($recordID, $category);
            }
        }
    }

    // public function debug($route)
    // {       
    //     return $this->addToCategoryCount($route, 'tester', 900, 'form_f4687');
    // }

    public function addBookmark($recordID)
    {
        if (!$this->hasReadAccess($recordID))
        {
            return 0;
        }
        $empUID = $this->portalUsers->getEmpUID(session('userID'));
        $this->records->addTag($recordID, 'bookmark_' . $empUID, $empUID);
    }

    public function deleteBookmark($recordID)
    {
        if (!$this->hasReadAccess($recordID))
        {
            return 0;
        }
        $empUID = $this->portalUsers->getEmpUID(session('userID'));
        $this->records->deleteTag($recordID, 'bookmark_' . $empUID, $empUID);
    }

    /**
     * Retrieves a form and includes any associated data, in a flat data array
     * @param int $recordID
     * @param string $limitCategory
     * @return array
     */
    public function getFullFormData($recordID, $limitCategory = null)
    {
        $fullForm = $this->getFullForm($recordID, $limitCategory);
        $output = array();

        $this->flattenFullFormData($fullForm, $output);

        return $output;
    }

    /**
     * Retrieves a form and includes any associated data, while retaining the form tree
     * @param int $recordID
     * @param string $limitCategory
     * @return array
     */
    public function getFullForm($recordID, $limitCategory = null)
    {
        $fullForm = array();

        // build the whole form structure
        $form = $this->getForm($recordID, $limitCategory);

        if (isset($form['items']))
        {
            foreach ($form['items'] as $section)
            {
                foreach ($section['children'] as $subsection)
                {
                    $fullForm = array_merge($fullForm, $this->getIndicator($subsection['indicatorID'], $subsection['series'], $recordID));
                }
            }
        }

        return $fullForm;
    }

    public function flattenFullFormData($data, &$output, $parentID = null)
    {
        foreach ($data as $key => $item)
        {
            if ($item['child'] == null)
            {
                unset($item['child']);
                $item['parentID'] = $parentID;
                $output[$item['indicatorID']][$item['series']] = $item;
            }
            else
            {
                $this->flattenFullFormData($item['child'], $output, $item['indicatorID']);
                unset($item['child']);
                $output[$item['indicatorID']][$item['series']] = $item;
            }
        }
    }

    /**
     * Get a form's indicator and all children, including data if available
     * @param int $indicatorID
     * @param int $series
     * @param int $recordID
     * @param bool $parseTemplate - parses html/htmlPrint template variables
     * @return array
     */
    public function getIndicator($indicatorID, $series, $recordID = null, $parseTemplate = true)
    {
        $form = array();
        if (!is_numeric($indicatorID) || !is_numeric($series))
        {
            return array();
        }

        // check needToKnow mode
        if ($recordID != null && $this->records->isNeedToKnow($recordID))
        {
            if (!$this->hasReadAccess($recordID))
            {
                return array();
            }
        }

        $data = $this->records->getIndicatorData($indicatorID, $series, $recordID);

        $required = isset($data[0]['required']) && $data[0]['required'] == 1 ? ' required="true" ' : '';

        $idx = $data[0]['indicatorID'];
        $form[$idx]['indicatorID'] = $data[0]['indicatorID'];
        $form[$idx]['series'] = $series;
        $form[$idx]['name'] = $data[0]['name'];
        $form[$idx]['description'] = $data[0]['description'];
        $form[$idx]['default'] = $data[0]['default'];
        $form[$idx]['parentID'] = $data[0]['parentID'];
        $form[$idx]['html'] = $data[0]['html'];
        $form[$idx]['htmlPrint'] = $data[0]['htmlPrint'];
        if($parseTemplate) {
            $form[$idx]['html'] = str_replace(['{{ iID }}', '{{ recordID }}'],
                                              [$idx, $recordID],
                                              $data[0]['html']);
            $form[$idx]['htmlPrint'] = str_replace(['{{ iID }}', '{{ recordID }}'],
                                              [$idx, $recordID],
                                              $data[0]['htmlPrint']);
        }
        $form[$idx]['required'] = $data[0]['required'];
        $form[$idx]['is_sensitive'] = $data[0]['is_sensitive'];
        $form[$idx]['isEmpty'] = (isset($data[0]['data']) && !is_array($data[0]['data']) && strip_tags($data[0]['data']) != '') ? false : true;
        $form[$idx]['value'] = (isset($data[0]['data']) && $data[0]['data'] != '') ? $data[0]['data'] : $form[$idx]['default'];
        $form[$idx]['value'] = @unserialize($form[$idx]['value']) === false ? $form[$idx]['value'] : unserialize($form[$idx]['value']);
        $form[$idx]['displayedValue'] = ''; // used for Org Charts
        $form[$idx]['timestamp'] = isset($data[0]['timestamp']) ? $data[0]['timestamp'] : 0;
        $form[$idx]['isWritable'] = $this->hasWriteAccess($recordID, $data[0]['categoryID']);
        $form[$idx]['isMasked'] = isset($data[0]['groupID']) ? $this->isMasked($data[0]['indicatorID'], $recordID) : 0;
        $form[$idx]['sort'] = $data[0]['sort'];

        // handle file upload
        if (isset($data[0]['data'])
            && ($data[0]['format'] == 'fileupload'
                || $data[0]['format'] == 'image'))
        {
            $form[$idx]['value'] = $this->fileToArray($data[0]['data']);
            $form[$idx]['raw'] = $data[0]['data'];
        }

        // special handling for org chart data types
        if ($data[0]['format'] == 'orgchart_employee'
            && isset($data[0]['data']))
        {
            $empRes = $this->employees->lookupEmpUID($data[0]['data']);
            $form[$idx]['displayedValue'] = "{$empRes[0]['firstName']} {$empRes[0]['lastName']}";
        }
        if ($data[0]['format'] == 'orgchart_position'
            && isset($data[0]['data']))
        {
            $positionTitle = $this->positions->getTitle($data[0]['data']);
            $form[$idx]['displayedValue'] = $positionTitle;
        }
        if ($data[0]['format'] == 'orgchart_group'
            && isset($data[0]['data']))
        {
            $groupTitle = $this->groups->getGroup($data[0]['data']);
            $form[$idx]['displayedValue'] = $groupTitle[0]['groupTitle'];
        }
        if (substr($data[0]['format'], 0, 4) == 'grid'
            && isset($data[0]['data']))
        {
            $values = @unserialize($data[0]['data']);
            $format = json_decode(substr($data[0]['format'], 5, -1) . ']');
            $form[$idx]['displayedValue'] = array_merge($values, array("format" => $format));
        }

        // prevent masked data from being output
        if ($form[$idx]['isMasked'])
        {
            $form[$idx]['value'] = '[protected data]';
            $form[$idx]['displayedValue'] = '[protected data]';
        }

        // handle radio/checkbox options
        $inputType = explode("\n", $data[0]['format']);
        $numOptions = count($inputType) > 1 ? count($inputType) : 0;
        for ($i = 1; $i < $numOptions; $i++)
        {
            $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
            if (strpos($inputType[$i], 'default:') !== false)
            {
                $form[$idx]['options'][] = array(substr($inputType[$i], 8), 'default');
            }
            else
            {
                $form[$idx]['options'][] = $inputType[$i];
            }
        }

        $form[$idx]['format'] = trim($inputType[0]);

        $form[$idx]['child'] = $this->buildFormTree($data[0]['indicatorID'], $series, $recordID, $parseTemplate);

        return $form;
    }

    /**
     * Checks if the current user has write access
     * Users should have write access if they are in "posession" of a request (they are currently reviewing it)
     * @param int $recordID
     * @param int $categoryID
     * @param int $indicatorID
     * @return int 1 = has access, 0 = no access
     */
    public function hasWriteAccess($recordID, $categoryID = 0, $indicatorID = 0)
    {
        // if an indicatorID is specified, find out what the indicator's categoryID is
        if (isset($this->cache["hasWriteAccess_{$recordID}_{$categoryID}_{$indicatorID}"]))
        {
            $categoryID = $this->cache["hasWriteAccess_{$recordID}_{$categoryID}_{$indicatorID}"];
        }
        else
        {
            if ($indicatorID != 0)
            {
                $res = $this->records->getIndicator($indicatorID);
                if (isset($res[0]['categoryID']))
                {
                    $categoryID = $res[0]['categoryID'];
                    $this->cache["hasWriteAccess_{$recordID}_{$categoryID}_{$indicatorID}"] = $categoryID;
                }
            }
        }

        $multipleCategories = array();
        if ($categoryID === 0
            && $indicatorID == 0)
        {
            $res = $this->records->getCategoryCount($recordID);

            foreach ($res as $type)
            {
                $categoryID .= $type['categoryID'];
                $multipleCategories[] = $type['categoryID'];
            }
        }

        // check cached result
        if (isset($this->cache["hasWriteAccess_{$recordID}_{$categoryID}"]))
        {
            return $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"];
        }

        $resRecords = null;
        if (isset($this->cache["resRecords_{$recordID}"]))
        {
            $resRecords = $this->cache["resRecords_{$recordID}"];
        }
        else
        {
            $resRecords = $this->records->getIsWritable($recordID);
            $this->cache["resRecords_{$recordID}"] = $resRecords;
        }

        // give the requestor access if the record explictly gives them write access
        if ($resRecords[0]['isWritableUser'] == 1
            && $this->portalUsers->getEmpUID(session('userID')) == $resRecords[0]['empUID'])
        {
            $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;

            return 1;
        }
        // give admins access
        if ($this->portalUsers->isAdmin(session('userID')))
        {
            $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;

            return 1;
        }

        // find out if explicit permissions have been granted to any groups
        if (count($multipleCategories) <= 1)
        {
            $resCategoryPrivs = $this->records->getCategoryPrivs($categoryID, $this->portalUsers->getEmpUID(session('userID')));
            if (count($resCategoryPrivs) > 0)
            {
                $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;

                return 1;
            }
        }
        else
        {
            foreach ($multipleCategories as $category)
            {
                $resCategoryPrivs = $this->records->getCategoryPrivs($categoryID, $this->portalUsers->getEmpUID(session('userID')));

                if (count($resCategoryPrivs) > 0)
                {
                    $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;

                    return 1;
                }
            }
        }

        // grant permissions to whoever currently "has" the form (whoever is the current approver)
        $resRecordPrivs = $this->records->getRecordPrivs($recordID);
        foreach ($resRecordPrivs as $priv)
        {
            if ($this->portalUsers->hasDependencyAccess(session('userID'),$priv['dependencyID'], $priv))
            {
                $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 1;

                return 1;
            }
        }

        // default no access
        $this->cache["hasWriteAccess_{$recordID}_{$categoryID}"] = 0;

        return 0;
    }

    /**
     * Check if field is masked/protected
     * @param int $indicatorID
     * @param int $recordID
     * @return int (0 = not masked, 1 = masked)
     */
    public function isMasked($indicatorID, $recordID = null)
    {
        $res = $this->records->getIndicatorMask($indicatorID);
        if (count($res) == 0)
        {
            return 0;
        }

        if (is_numeric($recordID) && ($this->getOwnerID($recordID) == session('userID')))
        {
            return 0;
        }
        foreach ($res as $indicator)
        {
            if ($this->portalUsers->checkGroup(session('userID'), $indicator['groupID']))
            {
                return 0;
            }
        }

        return 1;
    }

    public function getOwnerID($recordID)
    {
        if (isset($this->cache['owner_' . $recordID]))
        {
            return $this->cache['owner_' . $recordID];
        }
        $res = $this->records->getRecordIDFromRecord($recordID);
        $this->cache['owner_' . $recordID] = $res[0]['userID'];

        return $res[0]['userID'];
    }

    /**
     * Convert fileupload data into array
     * @param string $data
     * @return array
     */
    private function fileToArray($data)
    {
        $data = XSSHelpers::sanitizeHTML($data);
        $data = str_replace('<br />', "\n", $data);
        $data = str_replace('<br>', "\n", $data);
        $tmpFileNames = explode("\n", $data);
        $out = array();
        foreach ($tmpFileNames as $tmpFileName)
        {
            if (trim($tmpFileName) != '')
            {
                $out[] = $tmpFileName;
            }
        }

        return $out;
    }

    /**
     * Companion function to getIndicator()
     * @param int $id
     * @param int $series
     * @param int $recordID
     * @param bool $parseTemplate - see getIndicator()
     * @return array
     */
    private function buildFormTree($id, $series = null, $recordID = null, $parseTemplate = true)
    {
        if (!isset($this->cache["indicator_parentID{$id}"]))
        {
            $res = $this->records->getIndicatorsByParent($id);
            $this->cache["indicator_parentID{$id}"] = $res;
        }
        else
        {
            $res = $this->cache["indicator_parentID{$id}"];
        }

        $data = array();

        $child = null;
        if (count($res) > 0)
        {
            $indicatorArray = array();
            foreach ($res as $field)
            {
                if ($series != null && $recordID != null && is_numeric($field['indicatorID']))
                {
                    $indicatorArray[] = $field['indicatorID'];
                }
            }

            if ($series != null && $recordID != null)
            {
                $res2 = $this->records->getDataForIndicatorArray($indicatorArray, $series, $recordID);

                foreach ($res2 as $resIn)
                {
                    $idx = $resIn['indicatorID'];
                    $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';
                    $data[$idx]['timestamp'] = isset($resIn['timestamp']) ? $resIn['timestamp'] : 0;
                    $data[$idx]['groupID'] = isset($resIn['groupID']) ? $resIn['groupID'] : null;
                }
            }

            foreach ($res as $field)
            {
                $idx = $field['indicatorID'];

                
                $required = isset($field['required']) && $field['required'] == 1 ? ' required="true" ' : '';

                $child[$idx]['indicatorID'] = $field['indicatorID'];
                $child[$idx]['series'] = $series;
                $child[$idx]['name'] = $field['name'];
                $child[$idx]['default'] = $field['default'];
                $child[$idx]['description'] = $field['description'];
                $child[$idx]['html'] = $field['html'];
                $child[$idx]['htmlPrint'] = $field['htmlPrint'];
                if($parseTemplate) {
                    $child[$idx]['html'] = str_replace(['{{ iID }}', '{{ recordID }}'],
                                                      [$idx, $recordID],
                                                      $field['html']);
                    $child[$idx]['htmlPrint'] = str_replace(['{{ iID }}', '{{ recordID }}'],
                                                      [$idx, $recordID],
                                                      $field['htmlPrint']);
                }
                $child[$idx]['required'] = $field['required'];
                $child[$idx]['is_sensitive'] = $field['is_sensitive'];
                $child[$idx]['isEmpty'] = (isset($data[$idx]['data']) && !is_array($data[$idx]['data']) && strip_tags($data[$idx]['data']) != '') ? false : true;
                $child[$idx]['value'] = (isset($data[$idx]['data']) && $data[$idx]['data'] != '') ? $data[$idx]['data'] : $child[$idx]['default'];
                $child[$idx]['value'] = @unserialize($data[$idx]['data']) === false ? $child[$idx]['value'] : unserialize($data[$idx]['data']);
                $child[$idx]['timestamp'] = isset($data[$idx]['timestamp']) ? $data[$idx]['timestamp'] : 0;
                $child[$idx]['isWritable'] = $this->hasWriteAccess($recordID, $field['categoryID']);
                $child[$idx]['isMasked'] = isset($data[$idx]['groupID']) ? $this->isMasked($field['indicatorID'], $recordID) : 0;

                if ($child[$idx]['isMasked'])
                {
                    $child[$idx]['value'] = (isset($data[$idx]['data']) && $data[$idx]['data'] != '')
                                                ? '[protected data]' : '';
                }

                $inputType = explode("\n", $field['format']);
                $numOptions = count($inputType) > 1 ? count($inputType) : 0;
                for ($i = 1; $i < $numOptions; $i++)
                {
                    $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
                    if (strpos($inputType[$i], 'default:') !== false)
                    {
                        $child[$idx]['options'][] = substr($inputType[$i], 8); // legacy support
                    }
                    else
                    {
                        $child[$idx]['options'][] = $inputType[$i];
                    }
                }

                // handle file upload
                if (($field['format'] == 'fileupload'
                        || $field['format'] == 'image')
                    && isset($data[$idx]['data']))
                {
                    $child[$idx]['value'] = $this->fileToArray($data[$idx]['data']);
                }

                // special handling for org chart data types
                if ($field['format'] == 'orgchart_employee' && isset($data[$idx]['data']))
                {
                    $empRes = $this->employees->lookupEmpUID($data[$idx]['data']);
                    $child[$idx]['displayedValue'] = '';
                    if (isset($empRes[0]))
                    {
                        $child[$idx]['displayedValue'] = "{$empRes[0]['firstName']} {$empRes[0]['lastName']}";
                    }
                }
                if ($field['format'] == 'orgchart_position' && isset($data[$idx]['data']))
                {
                    $positionTitle = $this->positions->getTitle($data[$idx]['data']);
                    $child[$idx]['displayedValue'] = $positionTitle;
                }
                if ($field['format'] == 'orgchart_group' && isset($data[$idx]['data']))
                {
                    $groupTitle = $this->groups->getGroup($data[$idx]['data']);
                    $child[$idx]['displayedValue'] = $groupTitle[0]['groupTitle'];
                }

                $child[$idx]['format'] = trim($inputType[0]);

                $child[$idx]['child'] = $this->buildFormTree($field['indicatorID'], $series, $recordID);
            }
        }

        return $child;
    }

    /**
     * Retrieves a form in JSON format and includes any associated data,
     * in a flat data array, with additional fields that are required
     * when preparing a form to be digitally signed.
     *
     * @param int       $recordID       The record id to retrieve for signing
     * @param string    $limitCategory  The internal use form (optional)
     *
     * @return array    An array that represents the form ready for signing
     */
    public function getFullFormDataForSigning($recordID, $limitCategory = null)
    {
        // This function cannot use getFullFormData() above since that
        // function does not allow access to the $form object.
        // It uses the contents of getFullForm().

        // contents of getFullForm()
        // build the whole form structure
        $form = $this->getForm($recordID, $limitCategory);
        $fullForm = array();
        if (isset($form['items']))
        {
            foreach ($form['items'] as $section)
            {
                foreach ($section['children'] as $subsection)
                {
                    $fullForm = array_merge($fullForm, $this->getIndicator($subsection['indicatorID'], $subsection['series'], $recordID));
                }
            }
        }

        $indicators = array();
        $this->flattenFullFormData($fullForm, $indicators);

        $output = array(
            'userName' => session('userID'),
            'timestamp' => time(),
            'formId' => $form['items'][0]['children'][0]['type'],
            'recordId' => $recordID,
            'limitCategory' => $limitCategory != null ? $limitCategory : '',
            'indicators' => $indicators,
        );

        return $output;
    }

    public function setInitiator($recordID, $empUID)
    {
        if ($this->portalUsers->isAdmin(session('userID')))
        {
            $res = $this->records->updateInitiator($recordID, $empUID);

            // write log entry
            $user = $this->employees->VAMC_Directory_lookupLogin(session('userID'));
            $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : session('userID');

            $comment = "Initiator changed to {$name}";
            $this->actionHistory->insert($recordID, $empUID, 0, 'changeInitiator', 8, time(), $comment);

            return $empUID;
        }
    }

    public function test()
    {
        return $this->groups->getGroup(1);
    }
}
