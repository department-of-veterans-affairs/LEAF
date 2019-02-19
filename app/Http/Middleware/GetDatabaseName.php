<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Contracts\Filesystem\FileNotFoundException;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\File;

use Ramsey\Uuid\Uuid;

use App\Data\Repositories\Contracts\RoutesRepository;

class GetDatabaseName
{
    public static $req_cache_key_request_portal = "REQ_CACHE_RP";
    public static $req_cache_key_nexus = "REQ_CACHE_NX";

    private $routes;

    public function __construct(RoutesRepository $routes)
    {
        $this->routes = $routes;
    }

    private function buildNexusKey($uuid) {
        return $uuid . self::$req_cache_key_nexus;
    }

    private function buildPortalKey($uuid) {
        return $uuid . self::$req_cache_key_request_portal;
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
        $visn = $request->route('visn');

        if (!Cache::has($visn))
        {
            $route = $this->routes->getByName($visn);

            if ($route == null) 
            {
                // No route exists by that name
                return abort(404);
            }

            // To avoid putting the database name into the session info, generate a v4 UUID to attach to the request. 
            // This UUID is a cache key that can be accessed from the session to retrieve the database name associated with the URL.
            $uuid = Uuid::uuid4()->toString();

            $portalKey = $this->buildPortalKey($uuid);
            $nexusKey = $this->buildNexusKey($uuid);

            // put the UUIDs into the Cache
            Cache::forever($visn, $uuid);
            Cache::forever($portalKey, $route->portal_db);
            Cache::forever($nexusKey, $route->nexus_db);

            // put the UUIDs into the session, which is used to retrieve the database name
            $request->session()->put(self::$req_cache_key_request_portal, $portalKey);
            $request->session()->put(self::$req_cache_key_nexus, $nexusKey);
        }
        else
        {
            $uuid = Cache::get($visn);
            $portalKey = $this->buildPortalKey($uuid);
            $nexusKey = $this->buildNexusKey($uuid);
            // The URL has already been cached, so retrieve the UUIDs that are the cache keys for the database names
            // and add it to the session
            $request->session()->put(self::$req_cache_key_nexus, $nexusKey);
            $request->session()->put(self::$req_cache_key_request_portal, $portalKey);
        }

        return $next($request);
    }
}