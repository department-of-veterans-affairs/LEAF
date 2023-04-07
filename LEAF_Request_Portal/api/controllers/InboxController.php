<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class InboxController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $inbox;

    private $login;

    public function __construct($db, $login)
    {
        $this->inbox = new Inbox($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $inbox = $this->inbox;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('inbox/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('inbox/dependency/[text]', function ($args) use ($inbox) {
            return $inbox->getInbox($args[0]);
        });

        // TODO: This endpoint should be removed. Implementations of this in prod will need to be replaced
        // with inbox/dependency/[text]?masquerade=nonAdmin before this can be deleted.
        $this->index['GET']->register('inbox/dependency/[text]/nonadmin', function ($args) use ($inbox) {
            $_GET['masquerade'] = 'nonAdmin';
            return $inbox->getInbox($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $this->index['POST'] = new ControllerMap();
        $this->index['POST']->register('inbox', function ($args) {
        });

        return $this->index['POST']->runControl($act['key'], $act['args']);
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
