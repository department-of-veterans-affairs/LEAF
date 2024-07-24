<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Migration\AbstractMigration;

class OrgChart19 extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        $migrationContents = file_get_contents('../../LEAF_Nexus/db_upgrade/Update_OC_DB_3863-3872.sql');
        $this->execute($migrationContents);
    }

    /**
     * Migrate Down.
     */
    public function down()
    {
    }
}
