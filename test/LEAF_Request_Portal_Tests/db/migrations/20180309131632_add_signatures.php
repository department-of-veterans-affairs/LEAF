<?php


use Phinx\Migration\AbstractMigration;

/**
 * Adding support for persisting digital signatures.
 */
class AddSignatures extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        $this->execute(file_get_contents('../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5225-5226.sql'));
    }

    /**
     * Migrate Down.
     */
    public function down()
    {
        // Remove digital signature requirement
        $this->execute("ALTER TABLE `workflow_steps` DROP COLUMN `requiresDigitalSignature`;");

        // Remove the added action
        $this->execute("DELETE FROM `actions` WHERE `actionType` = 'sign';");

        // Remove the added column and foreign key
        $this->execute('ALTER TABLE `action_history` DROP FOREIGN KEY `signatures_id_fk`;');
        $this->execute('ALTER TABLE `action_history` DROP COLUMN `signature_id`;');

        // Drop the added table
        $this->execute('DROP TABLE `signatures`');

        // revert settings.setting dbversion
        $this->execute("UPDATE `settings` SET `data` = '5225' WHERE `settings`.`setting` = 'dbversion';");
    }
}
