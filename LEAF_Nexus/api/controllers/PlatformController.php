<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

use App\Leaf\XSSHelpers;

class PlatformController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $db;

    private $login;

    private $platform;

    public function __construct($db, $login, Platform $platform)
    {
        $this->db = $db;
        $this->login = $login;
        $this->platform = $platform;
    }

    public function get($act)
    {
        $verified = $this->login->getMembership();

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('platform/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('platform/portal', function ($args) use ($verified) {
            if (!isset($verified['groupID'][1])) {
                $return_value = 'You do not have access to this resource, only Admin\'s can delete Tags.';
            } else {
                $portals = $this->platform->getLaunchpadSites();
                $return_value = array();

                foreach ($portals as $portal) {
                    $sql = 'USE ' . $portal['portal_database'];
                    $this->db->query($sql);

                    $return_value[] = array(
                        'launchpadID' => $portal['launchpadID'],
                        'site_path' => $portal['site_path'],
                        'orgchartImportTags' => $this->platform->getTags($this->db)
                    );
                }
            }

            return $return_value;
        });



        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $this->index['POST'] = new ControllerMap();


        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // Not used in this file
    }
}
