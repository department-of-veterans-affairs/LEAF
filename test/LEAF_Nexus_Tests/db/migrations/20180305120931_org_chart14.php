<?php


use Phinx\Migration\AbstractMigration;

class OrgChart14 extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        $migrationContents = file_get_contents('../../LEAF_Nexus/db_upgrade/Update_OC_DB_3495-3520.sql');
        $this->execute($migrationContents);
    }

    /**
     * Migrate Down.
     */
    public function down()
    {
    }
}
