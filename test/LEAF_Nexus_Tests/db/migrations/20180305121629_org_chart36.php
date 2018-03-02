<?php


use Phinx\Migration\AbstractMigration;

class OrgChart36 extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        $migrationContents = file_get_contents('../../LEAF_Nexus/db_upgrade/Update_OC_DB_5158-5204.sql');
        $this->execute($migrationContents);
    }

    /**
     * Migrate Down.
     */
    public function down()
    {
    }
}
