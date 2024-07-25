<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Migration\AbstractMigration;

class OrgChart18 extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        $migrationContents = file_get_contents('../../LEAF_Nexus/db_upgrade/Update_OC_DB_3749-3863.sql');
        $this->execute($migrationContents);
    }

    /**
     * Migrate Down.
     */
    public function down()
    {
    }
}
