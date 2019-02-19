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
            'Nexus\Data\Repositories\Contracts\NexusUsersRepository',
            'Nexus\Data\Repositories\Dao\NexusUsersDao'
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
