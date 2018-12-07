<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Seed\AbstractSeed;

/**
 * A base set of data to test against.
 */
class BaseTestSeed extends AbstractSeed
{
    public function run()
    {
        $this->execute("
            START TRANSACTION;
            SET FOREIGN_KEY_CHECKS = 0;

            INSERT INTO `action_history`
            (`actionID`, `recordID`, `userID`, `stepID`, `dependencyID`, `actionType`, `actionTypeID`, `time`, `comment`) VALUES
            (1, 1, 'tester', 0, 5, 'submit', 6, 1520268930, '');

            INSERT INTO `categories`
            (`categoryID`, `parentID`, `categoryName`, `categoryDescription`, `workflowID`, `sort`, `needToKnow`, `formLibraryID`, `visible`, `disabled`) VALUES
            ('form_f4687', '', 'Sample Form', 'A Simple Sample Form', 1, 0, 0, NULL, 1, 0),
            ('form_f4688', '', 'Another Sample Form', 'Another Form for Testing', 2, 0, 0, NULL, 1, 0),
            ('form_f4689', '', 'Staple Form', 'A Staple form', 0, 0, 0, NULL, 1, 0);

            INSERT INTO `category_count`
            (`recordID`, `categoryID`, `count`) VALUES
            (1, 'form_f4687', 1);

            INSERT INTO `category_privs`
            (`categoryID`, `groupID`, `readable`, `writable`) VALUES
            ('form_f4687', 2, 1, 1);

            INSERT INTO `data`
            (`recordID`, `indicatorID`, `series`, `data`, `timestamp`, `userID`) VALUES
            (1, 2, 1, 'Bruce', 1520268869, 'tester'),
            (1, 3, 1, 'Wayne', 1520268875, 'tester'),
            (1, 4, 1, 'Vigilante Crime Fighter', 1520268925, 'tester'),
            (1, 5, 1, '<li>Fighting Crime</li><li>Wearing Capes</li><li>Ninja Stuff<br></li>', 1520268912, 'tester'),
            (1, 6, 1, '05/23/1934', 1520268896, 'tester'),
            (1, 7, 1, 'Cant see me', 1520268896, 'tester');

            INSERT INTO `data_history`
            (`recordID`, `indicatorID`, `series`, `data`, `timestamp`, `userID`) VALUES
            (1, 2, 1, 'Bruce', 1520268869, 'tester'),
            (1, 3, 1, 'Wayne', 1520268875, 'tester'),
            (1, 6, 1, '05/23/1934', 1520268896, 'tester'),
            (1, 5, 1, '<li>Fighting Crime</li><li>Wearing Capes</li><li>Ninja Stuff<br></li>', 1520268912, 'tester'),
            (1, 4, 1, 'Vigilante Crime Fighter', 1520268925, 'tester');

            INSERT INTO `groups`
            (`groupID`, `parentGroupID`, `name`, `groupDescription`) VALUES
            (2, NULL, 'Test Group', 'A Group for Testing'),
            (3, NULL, 'Another Test Group', 'Another Group for Testing');

            INSERT INTO `indicators` 
            (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `htmlPrint`, `jsSort`, `required`, `sort`, `timeAdded`, `disabled`, `is_sensitive`) VALUES
            (1, 'A Very Simple Form', '', '', '', NULL, 'form_f4687', NULL, NULL, NULL, 0, 1, '2018-03-05 16:52:15', 0, 1),
            (2, 'First Name', 'text', 'First Name', '', NULL, 'form_f4687', NULL, NULL, NULL, 1, 1, '2018-03-05 16:52:40', 0, 0),
            (3, 'Last Name', 'text', 'Last Name', '', NULL, 'form_f4687', NULL, NULL, NULL, 1, 1, '2018-03-05 16:52:54', 0, 0),
            (4, 'Occupation', 'text', 'Occupation', '', NULL, 'form_f4687', NULL, NULL, NULL, 0, 1, '2018-03-05 16:53:06', 0, 1),
            (5, 'Hobbies', 'textarea', 'Hobbies', '', NULL, 'form_f4687', NULL, NULL, NULL, 0, 1, '2018-03-05 16:53:30', 0, 1),
            (6, 'Favorite Day', 'date', 'favorite day', '', NULL, 'form_f4687', NULL, NULL, NULL, 1, 1, '2018-03-05 16:53:52', 0, 0),
            (7, 'Masked', 'text', 'Masked', '', NULL, 'form_f4687', NULL, NULL, NULL, 1, 1, '2018-03-05 16:53:52', 0, 1);

            INSERT INTO `indicator_mask`
            (`indicatorID`, `groupID`) VALUES
            (7, 1);

            INSERT INTO `records`
            (`recordID`, `date`, `serviceID`, `userID`, `title`, `priority`, `lastStatus`, `submitted`, `deleted`, `isWritableUser`, `isWritableGroup`) VALUES
            (1, 1520268853, 0, 'tester', 'My Request', 0, 'Submitted', 1520268930, 0, 0, 1);

            INSERT INTO `users`
            (`userID`, `groupID`) VALUES
            ('tester', 1),
            ('ninja', 2);

            INSERT INTO `workflows`
            (`workflowID`, `initialStepID`, `description`) VALUES
            (1, 0, 'Sample Workflow'),
            (2, 0, 'Another Workflow');

            INSERT INTO `workflow_steps` (`workflowID`, `stepID`, `stepTitle`, `stepBgColor`, `stepFontColor`, `stepBorder`, `jsSrc`, `posX`, `posY`, `indicatorID_for_assigned_empUID`)
            VALUES
	          (1, 1, 'A simple step', '#fffdcd', 'black', '1px solid black', '', NULL, NULL, NULL);


            INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`, `actionType`, `displayConditional`) VALUES
            (1, -1, 0, 'submit', '');

            INSERT INTO `settings` (`setting`, `data`) VALUES
            ('heading', ''),
            ('subheading', '');

            SET FOREIGN_KEY_CHECKS = 1;
            COMMIT;
        ");
    }
}
