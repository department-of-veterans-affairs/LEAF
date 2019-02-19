<?php

namespace RequestPortal\Providers;

use Illuminate\Support\ServiceProvider;

class RequestPortalRepositoryProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->bind(
            'RequestPortal\Data\Repositories\Contracts\FormsRepository',
            'RequestPortal\Data\Repositories\Dao\FormsDao'
        );

        $this->app->bind(
            'RequestPortal\Data\Repositories\Contracts\PortalUsersRepository',
            'RequestPortal\Data\Repositories\Dao\PortalUsersDao'
        );

        $this->app->bind(
            'RequestPortal\Data\Repositories\Contracts\RecordsRepository',
            'RequestPortal\Data\Repositories\Dao\RecordsDao'
        );

        $this->app->bind(
            'RequestPortal\Data\Repositories\Contracts\ServiceRepository',
            'RequestPortal\Data\Repositories\Dao\ServiceDao'
        );

        $this->app->bind(
            'RequestPortal\Data\Repositories\Contracts\SettingsRepository',
            'RequestPortal\Data\Repositories\Dao\SettingsDao'
        );
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
