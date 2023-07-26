<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class ActiveDirectoryController extends RESTfulResponse
{
    private $API_VERSION = 1;
    public $index = array();

    public function __construct($db, $login)
    {
        $this->dir = new ActiveDirectory($login);
    }
    // TODO: Connect to LDAP

    public function get($act)
    {
        $dir = $this->dir;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('ad/version', function () {
            return self::API_VERSION;
        });

        $this->index['GET']->register('ad/[digit]/title', function ($args) use ($dir) {
            return $dir->getTitle($args[0]);
        });

        $this->index['GET']->register('ad/[digit]', function ($args) use ($dir) {
            return $dir->getGroup($args[0]);
        });

        $this->index['GET']->register('ad/[digit]/members', function ($args) use ($dir) {
            return $dir->listMembers($args[0]);
        });
    }
}