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

    private int $API_VERSION = 1;    // Integer

    private $iconPicker;

    private $db;

    private $login;

    /**
     * Construct
     *
     * @param \Leaf\Db $db, Login $login
     */
    public function __construct($db, $login, $icon_path, $dynicon_index)
    {
        $this->login = $login;
        $this->icon_path = $icon_path;
        $this->dynicon_index = $dynicon_index;
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

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('iconPicker/list', function () use ($iconPicker, $icon, $dynicon) {
            return $iconPicker->getAllIcons($icon, $dynicon);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    /**
     * Purpose: Return JSON data depending on endpoint string passed.
     *
     * @param string $act
     * @return array
     */
    // public function post($act): array
    // {
    //     $workflow = $this->iconPicker;

    //     $this->verifyAdminReferrer();

    //     $this->index['POST'] = new ControllerMap();
    //     $this->index['POST']->register('iconpicker', function ($args) {
    //     });

    //     return $this->index['POST']->runControl($act['key'], $act['args']);
    // }
}
