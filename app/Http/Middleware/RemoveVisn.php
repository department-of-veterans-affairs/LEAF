<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Http\Middleware;

use Closure;
// use RP\Db\Config;
// use RP\Db\DB as RPDB;
// use RP\Db\DB_Config;
// use RP\Login as RPLogin;

class RemoveVisn
{

    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $request->route()->forgetParameter('visn'); 

        return $next($request);
    }
}
