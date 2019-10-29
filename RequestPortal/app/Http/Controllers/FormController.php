<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use LEAF\CommonConfig;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;
use RequestPortal\Data\Model\Record;
use RequestPortal\Data\Repositories\Contracts\FormsRepository;
use RequestPortal\Data\Repositories\Contracts\RecordsRepository;
use RequestPortal\Data\Repositories\Contracts\PortalUsersRepository;
use RequestPortal\Data\Repositories\Contracts\ServiceRepository;
// use RP\Form;
// use RP\Db\Config;
// use RP\Db\DB as RPDB;
// use RP\Db\DB_Config;
// use RP\Login as RPLogin;


class FormController extends Controller
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

    public function getAllForms()
    {
        return $this->forms->getAllForms();
    }
    
}