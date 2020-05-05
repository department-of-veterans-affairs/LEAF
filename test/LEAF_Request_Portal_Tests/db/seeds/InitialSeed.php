<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Seed\AbstractSeed;

/**
 * This is all data from LEAF_Request_Portal/resource_database_boilerplate.sql.
 * The inserts have been broken out here so the database does not need to be recreated just to seed the initial data.
 */
class InitialSeed extends AbstractSeed
{
    public function run()
    {
        $actionsData = "
            INSERT INTO `actions` (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`) VALUES
            ('approve', 'Approve', 'Approved', 'gnome-emblem-default.svg', 'right', 0, 1),
            ('concur', 'Concur', 'Concurred', 'go-next.svg', 'right', 1, 1),
            ('defer', 'Defer', 'Deferred', 'software-update-urgent.svg', 'left', 0, -2),
            ('disapprove', 'Disapprove', 'Disapproved', 'process-stop.svg', 'left', 0, -1),
            ('sendback', 'Send Back', 'Sent Back', 'edit-undo.svg', 'left', 0, 0),
            ('submit', 'Submit', 'Submitted', 'gnome-emblem-default.svg', 'right', 0, 1);
        ";
        $this->execute($actionsData);

        $actionTypesData = "
            INSERT INTO `action_types` (`actionTypeID`, `actionTypeDesc`) VALUES
            (1, 'approved'),
            (2, 'disapproved'),
            (3, 'deferred'),
            (4, 'deleted'),
            (5, 'undeleted'),
            (6, 'filled dependency'),
            (7, 'unfilled dependency'),
            (8, 'Generic');
        ";
        $this->execute($actionTypesData);

        $eventsData = "
            INSERT INTO `events` (`eventID`, `eventDescription`, `eventData`) VALUES
            ('std_email_notify_completed', 'Standard notification alerting requestor of approved request', ''),
            ('std_email_notify_next_approver', 'Standard Email Notification for next approver', '');
        ";
        $this->execute($eventsData);

        $groupsData = "
            INSERT INTO `groups` (`groupID`, `parentGroupID`, `name`, `groupDescription`) VALUES
            (-1, NULL, 'Quadrad', ''),
            (1, NULL, 'sysadmin', '');
        ";
        $this->execute($groupsData);

        $settingsData = "
            INSERT INTO `settings` (`setting`, `data`) VALUES
            ('dbversion', '3848'),
            ('version', '2240'),
            ('heading', 'Heading'),
            ('subheading', 'subHeading');
        ";
        $this->execute($settingsData);

        $dependenciesData = "
            INSERT INTO `dependencies` (`dependencyID`, `description`) VALUES
            ('-3', 'Group Designated by the Requestor'),
            ('-2', 'Requestor Followup'),
            ('-1', 'Person Designated by the Requestor'),
            ('1', 'Service Chief'),
            ('5', 'Request Submitted'),
            ('8', 'Quadrad');
        ";
        $this->execute($dependenciesData);
    }
}
