<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Migration\AbstractMigration;

class InitPortal extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        $migrationContents = file_get_contents('/var/www/db/boilerplate/resource_database_boilerplate.sql');
        $this->execute($migrationContents);
    }

    /**
     * Migrate Down.
     */
    public function down()
    {
        // Ignore any foreign key checks
        // ENSURE THIS GETS SET BACK TO 1
        $this->execute('SET FOREIGN_KEY_CHECKS = 0');

        $this->execute('DROP TABLE IF EXISTS actions');
        $this->execute('DROP TABLE IF EXISTS action_history');
        $this->execute('DROP TABLE IF EXISTS action_types');
        $this->execute('DROP TABLE IF EXISTS approvals');
        $this->execute('DROP TABLE IF EXISTS categories');
        $this->execute('DROP TABLE IF EXISTS category_count');
        $this->execute('DROP TABLE IF EXISTS category_dependencies');
        $this->execute('DROP TABLE IF EXISTS category_privs');
        $this->execute('DROP TABLE IF EXISTS category_staples');
        $this->execute('DROP TABLE IF EXISTS data');
        $this->execute('DROP TABLE IF EXISTS data_cache');
        $this->execute('DROP TABLE IF EXISTS data_extended');
        $this->execute('DROP TABLE IF EXISTS data_history');
        $this->execute('DROP TABLE IF EXISTS dependencies');
        $this->execute('DROP TABLE IF EXISTS dependency_privs');
        $this->execute('DROP TABLE IF EXISTS events');
        $this->execute('DROP TABLE IF EXISTS groups');
        $this->execute('DROP TABLE IF EXISTS indicators');
        $this->execute('DROP TABLE IF EXISTS indicator_mask');
        $this->execute('DROP TABLE IF EXISTS notes');
        $this->execute('DROP TABLE IF EXISTS pair_category_serviceiid');
        $this->execute('DROP TABLE IF EXISTS records');
        $this->execute('DROP TABLE IF EXISTS records_dependencies');
        $this->execute('DROP TABLE IF EXISTS records_step_fulfillment');
        $this->execute('DROP TABLE IF EXISTS records_workflow_state');
        $this->execute('DROP TABLE IF EXISTS route_events');
        $this->execute('DROP TABLE IF EXISTS services');
        $this->execute('DROP TABLE IF EXISTS service_chiefs');
        $this->execute('DROP TABLE IF EXISTS service_data');
        $this->execute('DROP TABLE IF EXISTS service_data_history');
        $this->execute('DROP TABLE IF EXISTS service_indicatorid');
        $this->execute('DROP TABLE IF EXISTS sessions');
        $this->execute('DROP TABLE IF EXISTS settings');
        $this->execute('DROP TABLE IF EXISTS step_dependencies');
        $this->execute('DROP TABLE IF EXISTS tags');
        $this->execute('DROP TABLE IF EXISTS users');
        $this->execute('DROP TABLE IF EXISTS workflows');
        $this->execute('DROP TABLE IF EXISTS workflow_routes');
        $this->execute('DROP TABLE IF EXISTS workflow_steps');
        $this->execute('DROP TABLE IF EXISTS signatures');
        $this->execute('DROP TABLE IF EXISTS short_links');
        $this->execute('DROP TABLE IF EXISTS step_modules');

        // Stop ignoring foreign key checks
        // ENSURE THIS GETS SET BACK TO 1
        $this->execute('SET FOREIGN_KEY_CHECKS = 1');
    }
}
