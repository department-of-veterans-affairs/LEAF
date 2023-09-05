<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

// Since Groups are primarily controlled via the Org. Chart, this provides read access to the local group database.

namespace Portal;

use App\Leaf\XSSHelpers;

class GroupController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;    // Integer

    private $group;

    private $login;

    public function __construct($db, $login)
    {
        $this->group = new Group($db, $login);
        $this->login = $login;
    }

    public function get($act)
    {
        $group = $this->group;

        $this->index['GET'] = new ControllerMap();
        $cm = $this->index['GET'];
        $this->index['GET']->register('group/version', function () {
            return $this->API_VERSION;
        });

        $this->index['GET']->register('group/list', function ($args) use ($group) {
            return $group->getGroupsList();
        });

        $this->index['GET']->register('group/members', function ($args) use ($group) {
            $return = $group->getGroupsAndMembers();
            return $return;
        });

        $this->index['GET']->register('group/members/all', function ($args) use ($group) {
            return $group->getGroupsAndMembers(true);
        });

        $this->index['GET']->register('group/[digit]/membersWBackups', function ($args) use ($group) {
            $members = $group->getMembers($args[0], false, true);
            return $members;
        });

        $this->index['GET']->register('group/[digit]/members', function ($args) use ($group) {
            $members = $group->getMembers($args[0]);
            $users = array();

            foreach ($members['data'] as $key => $value) {
                if ($members['data'][$key]['backupID'] == '') {
                    $members['data'][$key]['backupID'] = null;
                }
            }
            return $members['data'];
        });

        $this->index['GET']->register('group/[digit]/list_members', function ($args) use ($group) {
            return $group->getMembers($args[0]);
        });

        $this->index['GET']->register('group/[digit]/associated_workflows', function ($args) use ($group) {
            return $group->getWorkflows($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $group = $this->group;

            $this->index['POST'] = new ControllerMap();

            $this->index['POST']->register('group', function ($args) use ($group) {
                return $group->addGroup(XSSHelpers::sanitizeHTML($_POST['title'])); // POST for title of group
            });

            // Controller for Import Group
            $this->index['POST']->register('group/import', function ($args) use ($group) {
                return $group->importGroup(XSSHelpers::sanitizeHTML($_POST['title'])); // POST for title of group
            });

            $this->index['POST']->register('group/[digit]/members/[text]/reactivate', function ($args) use ($group) {
                return $group->reActivateMember($args[1], $args[0]);
            });

            $this->index['POST']->register('group/[digit]/members/[text]/prune', function ($args) use ($group) {
                return $group->removeMember($args[1], $args[0]);
            });

            $this->index['POST']->register('group/[digit]/members/[text]', function ($args) use ($group) {
                return $group->deactivateMember($args[1], $args[0]);
            });

            $this->index['POST']->register('group/[digit]/members', function ($args) use ($group) {
                return $group->addMember($_POST['userID'], $args[0]);
            });

            return $this->index['POST']->runControl($act['key'], $act['args']);
        }
    }

    public function delete($act)
    {
        $verified = $this->verifyAdminReferrer();

        if ($verified) {
            echo $verified;
        } else {
            $group = $this->group;

            $this->index['DELETE'] = new ControllerMap();

            $this->index['DELETE']->register('group/[digit]', function ($args) use ($group) {
                return $group->removeGroup($args[0]);
            });

            $this->index['DELETE']->register('group/[digit]/members/[text]', function ($args) use ($group) {
                return $group->removeMember($args[1], $args[0]);
            });

            return $this->index['DELETE']->runControl($act['key'], $act['args']);
        }
    }
}
