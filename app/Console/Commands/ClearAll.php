<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;

class ClearAll extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'clear:dev';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clear the app, config, and route caches';

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
        Artisan::call('cache:clear');
        $this->info('Cleared application cache');
        Artisan::call('config:clear');
        $this->info('Cleared configuration cache');
        Artisan::call('route:clear');
        $this->info('Cleared route cache');
    }
}
