<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Http\Middleware;

use Closure;
use Nexus\Data\Repositories\Contracts\NexusUsersRepository;
// use RP\Db\Config;
// use RP\Db\DB as RPDB;
// use RP\Db\DB_Config;
// use RP\Login as RPLogin;

class IsAuth
{
    /**
     * The Nexus Users repository
     *
     * @var NexusUsersRepository
     */
    protected $users;

    public function __construct(NexusUsersRepository $users)
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
