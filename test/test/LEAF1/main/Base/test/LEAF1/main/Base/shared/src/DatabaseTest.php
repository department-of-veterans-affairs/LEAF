<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Console\PhinxApplication;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Console\Input\StringInput;
use Symfony\Component\Console\Output\NullOutput;

/**
 * Helper class for seeding the database.
 *
 * The Phinx commands will use whatever phinx.yml is located in the
 * directory that the PHPUnit command line argument is being run from.
 *
 * That is, if the tests are being run from LEAF_Nexus_Tests, it will
 * use LEAF_Nexus_Tests/phinx.yml.
 */
class DatabaseTest extends TestCase
{
    /**
     * Populates the database with any default data from a fresh install.
     * It does not tear down and rebuild the database, just inserts data.
     */
    public function initialSeed() : void
    {
        $this->runPhinxCmd('seed:run -s InitialSeed');
    }

    /**
     * Truncates all tables, seeds with initial data, seeds with base test data.
     */
    public function resetDatabase() : void
    {
        $this->truncateTables();
        $this->initialSeed();
        $this->seedBaseTestData();
    }

    /**
     * Seed the database with a base set of data to test against.
     */
    public function seedBaseTestData() : void
    {
        $this->runPhinxCmd('seed:run -s BaseTestSeed');
    }

    /**
     * Remove ALL data from ALL tables. Does not drop the tables or database.
     */
    public function truncateTables() : void
    {
        $this->runPhinxCmd('seed:run -s TruncateTables');
    }

    private function runPhinxCmd($cmd) : void
    {
        $app = new PhinxApplication();
        $app->setAutoExit(false);
        $app->run(new StringInput($cmd), new NullOutput());
    }
}
