<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CreateRoutesDB extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:routes:create';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create the LEAF Routes database';

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
        try
        {
            DB::connection('admin')->statement('CREATE DATABASE `leaf_routes` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
            $this->info('Created "leaf_routes" database.');
        } 
        catch (\PDOException $exception)
        {
            $this->error('Could NOT create "leaf_routes" database.');
        }
    }
}
