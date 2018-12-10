<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Migration\AbstractMigration;

class Portal01 extends AbstractMigration
{
    /**
     * Migrate Up.
     */
    public function up()
    {
        // TODO: one day these should all be broken out into separate migration files... but not today
        $files = array(
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_0-1207.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1207-1301.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1301-1374.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1374-1441.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1441-1464.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1464-1475.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1475-1500.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1500-1550.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1550-1551.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1551-1552_U.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1552-1597.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1597-1621.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1621-1644.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1706-1711.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_1711-2038.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_2038-2257.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_2257-2884.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_2884-2945.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_2945-3008.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3008-3013.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3013-3018.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3018-3030.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3030-3032.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3032-3059.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3059-3132.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3132-3133.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3133-3134.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3134-3135.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3135-3229.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3229-3270.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3270-3275.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3275-3495.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3495-3657.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3657-3820.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3820-3842.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3842-3846.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3846-3847.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3847-3848.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_3848-4290.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4290-4291.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4291-4300.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4300-4344.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4344-4346.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4346-4371.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4371-4429.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4429-4482.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4482-4598.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4598-4691.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4691-4763.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4763-4866.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4866-4886.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4886-4936.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4936-4941.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4941-4951.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4951-4968.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4968-4985.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_4985-5008.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5008-5099.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5099-5150.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5150-5164.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5164-5192.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5192-5213.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5213-5219.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5219-5225.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5225-5293.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5293-5299.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5299-5348.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5348-5360.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5360-5366.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5366-5367.sql',
        '../../LEAF_Request_Portal/utils/db_upgrade/Update_RMC_DB_5367-5372.sql',
      );

        foreach ($files as $file)
        {
            echo 'Migrating: ' . $file . "\n";
            $this->execute(file_get_contents($file));
        }
    }

    /**
     * Migrate Down.
     */
    public function down()
    {
    }
}
