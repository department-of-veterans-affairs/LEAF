<?php

namespace Nexus\Providers;

use Illuminate\Support\ServiceProvider;

class NexusRepositoryProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->bind(
            'Nexus\Data\Repositories\Contracts\DataRepository',
            'Nexus\Data\Repositories\Dao\DataDao'//todo this shit
        );

        $this->app->bind(
            'Nexus\Data\Repositories\Contracts\EmployeesRepository',
            'Nexus\Data\Repositories\Dao\EmployeesDao'
        );

        $this->app->bind(
            'Nexus\Data\Repositories\Contracts\GroupsRepository',
            'Nexus\Data\Repositories\Dao\GroupsDao'
        );

        $this->app->bind(
            'Nexus\Data\Repositories\Contracts\PositionsRepository',
            'Nexus\Data\Repositories\Dao\PositionsDao'
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
