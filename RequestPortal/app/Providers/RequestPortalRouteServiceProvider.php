<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Providers;

use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Route;

class RequestPortalRouteServiceProvider extends ServiceProvider
{
    /**
     * This namespace is applied to your controller routes.
     *
     * In addition, it is set as the URL generator's root namespace.
     *
     * @var string
     */
    protected $namespace = 'RequestPortal\Http\Controllers';

    /**
     * Define your route model bindings, pattern filters, etc.
     *
     * @return void
     */
    public function boot()
    {
        // Common request parameter patterns
        Route::pattern('indicatorID', '[0-9]+');
        Route::pattern('requestID', '[0-9]+');
        Route::pattern('serviceID', '[0-9]+');
        Route::pattern('categoryID', '[a-zA-Z0-9]+');

        parent::boot();
    }

    /**
     * Define the routes for the application.
     *
     * @return void
     */
    public function map()
    {
        $this->mapApiRoutes();
        $this->mapWebRoutes();
    }

    /**
     * Define the "web" routes for the application.
     *
     * These routes all receive session state, CSRF protection, etc.
     *
     * @return void
     */
    protected function mapWebRoutes()
    {
        // Middleware is defined in app\Http\Kernel.php
        Route::middleware('dbweb')
            ->prefix('portal')
            ->namespace($this->namespace)
            ->group(base_path('RequestPortal/routes/web.php'));
    }

    /**
     * Define the "api" routes for the application.
     *
     * These routes are typically stateless.
     *
     * @return void
     */
    protected function mapApiRoutes()
    {
        Route::prefix('api/portal')
            ->middleware('api')
            ->namespace($this->namespace)
            ->group(base_path('RequestPortal/routes/api.php'));
    }
}
