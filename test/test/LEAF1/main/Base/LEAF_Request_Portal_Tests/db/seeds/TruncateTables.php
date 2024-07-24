<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Seed\AbstractSeed;

/**
 * Empties the Request Portal database of all data.
 * To repopulate with initial data, seed with IntialSeed.
 */
class TruncateTables extends AbstractSeed
{
    public function run()
    {
        // Ignore any foreign key checks
        // ENSURE THIS GETS SET BACK TO 1
        $this->execute('SET FOREIGN_KEY_CHECKS = 0');

        $this->table('actions')->truncate();
        $this->table('action_history')->truncate();
        $this->table('action_types')->truncate();
        $this->table('approvals')->truncate();
        $this->table('categories')->truncate();
        $this->table('category_count')->truncate();
        $this->table('category_privs')->truncate();
        $this->table('category_staples')->truncate();
        $this->table('data')->truncate();
        $this->table('data_cache')->truncate();
        $this->table('data_extended')->truncate();
        $this->table('data_history')->truncate();
        $this->table('dependencies')->truncate();
        $this->table('dependency_privs')->truncate();
        $this->table('events')->truncate();
        $this->table('groups')->truncate();
        $this->table('indicators')->truncate();
        $this->table('indicator_mask')->truncate();
        $this->table('notes')->truncate();
        $this->table('records')->truncate();
        $this->table('records_dependencies')->truncate();
        $this->table('records_step_fulfillment')->truncate();
        $this->table('records_workflow_state')->truncate();
        $this->table('route_events')->truncate();
        $this->table('services')->truncate();
        $this->table('service_chiefs')->truncate();
        $this->table('sessions')->truncate();
        $this->table('settings')->truncate();
        $this->table('step_dependencies')->truncate();
        $this->table('tags')->truncate();
        $this->table('users')->truncate();
        $this->table('workflows')->truncate();
        $this->table('workflow_routes')->truncate();
        $this->table('workflow_steps')->truncate();

        // Stop ignoring foreign key checks
        // ENSURE THIS GETS SET BACK TO 1
        $this->execute('SET FOREIGN_KEY_CHECKS = 1');
    }
}
