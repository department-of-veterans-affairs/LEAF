<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Seed\AbstractSeed;

/**
 * Empties the Nexus database of all data.
 * To repopulate with initial data, seed with IntialSeed.
 */
class TruncateTables extends AbstractSeed
{
    public function run()
    {
        $this->table('categories')->truncate();
        $this->table('employee')->truncate();
        $this->table('employee_data')->truncate();
        $this->table('employee_data_history')->truncate();
        $this->table('employee_privileges')->truncate();
        $this->table('groups')->truncate();
        $this->table('group_data')->truncate();
        $this->table('group_data_history')->truncate();
        $this->table('group_privileges')->truncate();
        $this->table('group_tags')->truncate();
        $this->table('indicators')->truncate();
        $this->table('indicator_privileges')->truncate();
        $this->table('positions')->truncate();
        $this->table('position_data')->truncate();
        $this->table('position_data_history')->truncate();
        $this->table('position_privileges')->truncate();
        $this->table('position_tags')->truncate();
        $this->table('relation_employee_backup')->truncate();
        $this->table('relation_group_employee')->truncate();
        $this->table('relation_group_position')->truncate();
        $this->table('relation_position_employee')->truncate();
        $this->table('sessions')->truncate();
        $this->table('settings')->truncate();
        $this->table('tag_hierarchy')->truncate();
    }
}
