<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Leaf;

use App\Leaf\Db;

class DbUpdate
{
    private $db;

    private $setting;

    private $current_version;

    private $portal_path;

    private $EOL;

    private $message = '';

    private $update_list = [];

    private $folder = '/var/www/db/db_upgrade/';

    private $prefix = '/Update_RMC_DB_';

    /**
     * @param Db $db
     *
     * Created at: 9/5/2023, 10:56:00 AM (America/New_York)
     */
    /**
     * @param Db $db // this needs to be the correct db for what you want to update (portal or orgchart)
     * @param Setting $setting
     * @param string $portal // portal or orgchart
     * @param string $portal_path
     *
     * Created at: 10/27/2023, 2:04:29 PM (America/New_York)
     */
    public function __construct(Db $db, Setting $setting, string $portal, string $portal_path)
    {
        $this->db = $db;
        $this->setting = $setting;
        $this->folder .= $portal;
        $this->portal_path = $portal_path;

        $this->setEOL();
        $this->getUpdateList();

        $this->initilize();
    }

    public function initilize(): void
    {
        $settings = $this->setting->getSettings();

        $this->current_version = $settings['dbversion'];
    }

    public function run()
    {
        $this->message .= 'Current Database Version: ' . $this->current_version . $this->EOL . $this->EOL;

        if (isset($this->update_list[$this->current_version])) {
            $this->message .= 'Update found: ' . $this->update_list[$this->current_version] . $this->EOL;

            $update = file_get_contents($this->folder . $this->update_list[$this->current_version]);

            $this->message .= 'Processing update for ' . $this->portal_path . ' ...' . $this->EOL;

            $this->db->prepared_query($update, array());

            $this->message .= ' ... Complete' . $this->EOL;

            $this->setting->initilize();

            $settings = $this->setting->getSettings();

            if ($settings['dbVersion'] == $this->current_version) {
                $this->message .= 'Portal Db Update failed.' . $this->EOL . $this->EOL;
            } else {
                $this->message .= 'Database updated to: '. $settings['dbVersion'] . $this->EOL . $this->EOL;
                $this->initilize();
                $this->run();
            }
        }

        $this->message .= 'Complete';
    }

    public function getMessage()
    {
        return $this->message;
    }

    private function setEOL()
    {
        if (php_sapi_name() == 'cli') {
            $this->EOL = "\r\n";
        } else {
            $this->EOL = '<br />';
        }
    }

    private function getUpdateList()
    {
        $updates = scandir($this->folder);

        foreach ($updates as $update) {
            $version = substr($update, strlen($this->prefix . $this->current_version) - strlen($this->current_version));
            $index = strpos($version, '-');
            $old_version = substr($version, 0, $index);

            if (is_numeric($old_version)) {
                $this->update_list[$old_version] = $update;
            }
        }
    }
}