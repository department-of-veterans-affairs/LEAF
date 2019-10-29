<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Nexus\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use LEAF\CommonConfig;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;
use Nexus\Data\Model\Employee;

class EmployeesController extends Controller
{
    /**
     * Employees Repository
     *
     * @var EmployeesRepository
     */
    protected $employees;

    private $cache = array();

    public function __construct(EmployeesRepository $employees)
    {
        $this->middleware(array('IsAuth', 'GetDatabaseName'));
        $this->employees = $employees;
    }
    
}