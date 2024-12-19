<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class ActiveDirectoryController extends RESTfulResponse
{
    private $API_VERSION = 1;
    public $index = array();

    public $dir;

    public function __construct()
    {
        $this->dir = new ActiveDirectory();
    }

    public function get($act)
    {
        $dir = $this->dir;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('ad/version', function () {
            return self::API_VERSION;
        });

        $this->index['GET']->register('ad/member/[text]', function ($args) use ($dir) {
            return $dir->searchMember($args[0]);
        });

        $this->index['GET']->register('ad/group/[text]', function ($args) use ($dir) {
            return $dir->searchGroup($args[0]);
        });

        $this->index['GET']->register('ad/[digit]/members', function ($args) use ($dir) {
            return $dir->listMembers($args[0]);
        });
    }

    public function post($act) {}

    public function delete($act) {}
}