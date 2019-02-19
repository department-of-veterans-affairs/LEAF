<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;

class MigrateRoutesDB extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:routes:migrate';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Run migrations on the Routes database';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $exitCode = Artisan::call('migrate', ['--database' => "routes"]);
        if ($exitCode !== 0)
        {
            $this->error("Could not run migrations on leaf_routes table");
        }
        else
        {
            $this->info("Migrations successfully complete on leaf_routes");
        }
    }
}
