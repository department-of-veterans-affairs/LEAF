<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class IconPickerController extends RESTfulResponse
{
    public $index = array();

    protected $icon_path;

    protected $dynicon_index;

    protected $domain;

    private int $API_VERSION = 1;    // Integer

    private $iconPicker;

    private $db;

    private $login;

    /**
     * Construct
     *
     * @param \App\Leaf\Db $db, Login $login
     */
    public function __construct($db, $login, $icon_path, $dynicon_index, $domain)
    {
        $this->login = $login;
        $this->icon_path = $icon_path;
        $this->dynicon_index = $dynicon_index;
        $this->domain = $domain;
        $this->iconPicker = new IconPicker($db, $login);
    }

    /**
     * Purpose: Return JSON data depending on endpoint string passed.
     *
     * @param array $act
     *
     */
    public function get($act)
    {
        $db = $this->db;
        $login = $this->login;
        $iconPicker = $this->iconPicker;
        $icon = $this->icon_path;
        $dynicon = $this->dynicon_index;
        $domain = $this->domain;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('iconPicker/list', function () use ($iconPicker, $icon, $dynicon, $domain) {
            return $iconPicker->getAllIcons($icon, $dynicon, $domain);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
