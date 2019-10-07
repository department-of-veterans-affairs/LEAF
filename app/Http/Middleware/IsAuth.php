<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Http\Middleware;

use Closure;
use Nexus\Data\Repositories\Contracts\EmployeesRepository;
// use RP\Db\Config;
// use RP\Db\DB as RPDB;
// use RP\Db\DB_Config;
// use RP\Login as RPLogin;

class IsAuth
{
    /**
     * The Employees repository
     *
     * @var EmployeesRepository
     */
    protected $users;

    public function __construct(EmployeesRepository $users)
    {
        $this->users = $users;
    }

    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        session(['userID' => 'tester']);
        session(['empUID' => '44o64a5f-cf55-11o9-bad9-645d863o34f5']);

        // $db_config = new DB_Config();
        // $config = new Config();
        // $db = new RPDB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);
        // $db_phonebook = new RPDB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
        // $login = new RPLogin($db_phonebook, $db);
        // $login->loginUser();
        // if (!$login->isLogin() || !$login->isInDB())
        // {
        //     $login->logout();
        //     abort(503);
        // }

        if (!session()->has('userID'))
        {
            return redirect('/login');
        }

        $user = $this->users->getByUsername(session('userID'));

        if ($user == null || $user->userName == null)
        {
            abort(403);
        } 

        return $next($request);
    }
}
