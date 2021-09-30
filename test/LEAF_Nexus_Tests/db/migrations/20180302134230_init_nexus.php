<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Migration\AbstractMigration;

class InitNexus extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        $migrationContents = file_get_contents('/var/www/db/boilerplate/orgchart_boilerplate_empty.sql');
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

        $this->execute('DROP TABLE IF EXISTS cache');
        $this->execute('DROP TABLE IF EXISTS categories');
        $this->execute('DROP TABLE IF EXISTS employee');
        $this->execute('DROP TABLE IF EXISTS employee_data');
        $this->execute('DROP TABLE IF EXISTS employee_data_history');
        $this->execute('DROP TABLE IF EXISTS employee_privileges');
        $this->execute('DROP TABLE IF EXISTS groups');
        $this->execute('DROP TABLE IF EXISTS group_data');
        $this->execute('DROP TABLE IF EXISTS group_data_history');
        $this->execute('DROP TABLE IF EXISTS group_privileges');
        $this->execute('DROP TABLE IF EXISTS group_tags');
        $this->execute('DROP TABLE IF EXISTS indicators');
        $this->execute('DROP TABLE IF EXISTS indicator_privileges');
        $this->execute('DROP TABLE IF EXISTS positions');
        $this->execute('DROP TABLE IF EXISTS position_data');
        $this->execute('DROP TABLE IF EXISTS position_data_history');
        $this->execute('DROP TABLE IF EXISTS position_privileges');
        $this->execute('DROP TABLE IF EXISTS position_tags');
        $this->execute('DROP TABLE IF EXISTS relation_employee_backup');
        $this->execute('DROP TABLE IF EXISTS relation_group_employee');
        $this->execute('DROP TABLE IF EXISTS relation_group_position');
        $this->execute('DROP TABLE IF EXISTS relation_position_employee');
        $this->execute('DROP TABLE IF EXISTS sessions');
        $this->execute('DROP TABLE IF EXISTS settings');
        $this->execute('DROP TABLE IF EXISTS tag_hierarchy');

        // Stop ignoring foreign key checks
        // ENSURE THIS GETS SET BACK TO 1
        $this->execute('SET FOREIGN_KEY_CHECKS = 1');
    }
}
