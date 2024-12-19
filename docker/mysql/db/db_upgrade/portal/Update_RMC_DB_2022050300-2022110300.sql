START TRANSACTION;


ALTER TABLE `workflow_steps`
    ADD COLUMN `stepData` TEXT NULL
    AFTER `requiresDigitalSignature`;

INSERT INTO `email_templates` (`emailTemplateID`, `label`, `emailTo`, `emailCc`, `subject`, `body`)
VALUES ('-5', 'Automated Email Reminder', 'LEAF_automated_reminder_emailTo.tpl', 'LEAF_automated_reminder_emailCc.tpl', 'LEAF_automated_reminder_subject.tpl', 'LEAF_automated_reminder_body.tpl');

ALTER TABLE `records_workflow_state`
    ADD COLUMN `lastNotified` timestamp DEFAULT CURRENT_TIMESTAMP
    AFTER `blockingStepID`;

UPDATE `settings` SET `data` = '2022110300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `workflow_steps` DROP COLUMN `stepData`;

DELETE FROM `email_templates` WHERE  `emailTemplateID`=-5;

ALTER TABLE `records_workflow_state` DROP COLUMN `lastNotified`;

UPDATE `settings` SET `data` = '2022050300' WHERE `settings`.`setting` = 'dbversion';


COMMIT;

*/
