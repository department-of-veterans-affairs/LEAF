START TRANSACTION;

INSERT INTO `email_templates` (`emailTemplateID`, `label`, `emailTo`, `emailCc`, `subject`, `body`)
VALUES ('-6', 'Automated Step Change Reminder', 'LEAF_automated_step_change_reminder_emailTo.tpl', 'LEAF_automated_step_change_reminder_emailCc.tpl', 'LEAF_automated_step_change_reminder_subject.tpl', 'LEAF_automated_step_change_reminder_body.tpl');

UPDATE `settings` SET `data` = '2024051700' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DELETE FROM `email_templates` WHERE `emailTemplateID` = -6;

 UPDATE `settings` SET `data` = '2024022901' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */
