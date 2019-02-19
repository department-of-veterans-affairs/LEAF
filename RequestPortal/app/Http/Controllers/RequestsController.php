<?php

namespace RequestPortal\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use RequestPortal\Data\Repositories\Contracts\RecordsRepository;
use RequestPortal\Data\Repositories\Contracts\ServiceRepository;
use RequestPortal\Data\Repositories\Contracts\FormsRepository;

use RequestPortal\Data\Model\Record;

// use RP\Form;
// use RP\Db\Config;
// use RP\Db\DB as RPDB;
// use RP\Db\DB_Config;
// use RP\Login as RPLogin;
use LEAF\CommonConfig;

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

    protected $oldForm;

    private $cache = array();

    public function __construct(RecordsRepository $records, ServiceRepository $services, FormsRepository $forms)
    {
        $this->middleware(['IsAuth', 'GetDatabaseName']);
        $this->records = $records;
        $this->services = $services;
        $this->forms = $forms;

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


    public function getAll($route)
    {
        return view('records', [
            'records' => $this->records->getAll(),
            'visn' => $route
        ]);
    }

    public function getById($route, $id)
    {
        return view('records', [
            'records' => $this->records->getById($id),
            'visn' => $route
        ]);
    }

    public function create($route)
    {
        return view('newrecord', ['visn' => $route]);
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
            return redirect("/welcome");
        }

        $res = $this->services->getById($service);
        $serviceID = $res != null ? $res->serviceID : null;

        if (!is_numeric($serviceID)) {
            if ($service == 0)
            {
                $serviceID = 0;
            }
            else 
            {
                // TODO: redirect to error page saying "Error: Service ID is not synchronized to Org. Chart."
                return redirect("/welcome");
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

                if ($tCount >= 1) {
                    $categoryID = strtolower(substr($key, 3));

                    if($this->isCategory($categoryID))
                    {
                        $this->forms->createFormCount($recordID, $categoryID, $tCount);

                        $res = $this->forms->getStapledForms($categoryID);

                        foreach($res as $merged)
                        {
                            $this->forms->createFormCount($recordID, $merged->stapledCategoryID, $tCount);
                        }
                    }
                }
            }
        }

        return redirect()->route('request.detail', [
            "visn" => $route, "requestId" => $recordID
        ]);
    }

    public function updateIndicator(Request $request, $route, $recordId, $indicatorId) 
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
}
