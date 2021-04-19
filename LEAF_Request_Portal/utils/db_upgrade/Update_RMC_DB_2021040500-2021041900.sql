START TRANSACTION;

ALTER TABLE `email_templates`
    ADD COLUMN `emailTo` text NULL AFTER `label`,
    ADD COLUMN `emailCc` text NULL AFTER `emailTo`;

INSERT INTO `email_templates` (emailTemplateID, label, emailTo, emailCc, subject, body)
VALUES (1, 'Default Email Template', '', '', '', 'LEAF_main_email_template.tpl');
UPDATE `email_templates` SET `emailTo` = 'LEAF_notify_complete_emailTo.tpl', `emailCc` = 'LEAF_notify_complete_emailCc.tpl' WHERE `emailTemplateID` = -3;
UPDATE `email_templates` SET `emailTo` = 'LEAF_notify_next_emailTo.tpl', `emailCc` = 'LEAF_notify_next_emailCc.tpl' WHERE `emailTemplateID` = -2;
UPDATE `email_templates` SET `emailTo` = 'LEAF_send_back_emailTo.tpl',	`emailCc` = 'LEAF_send_back_emailCc.tpl' WHERE `emailTemplateID` = -1;

UPDATE `settings` SET `data` = '2021041900' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `email_templates`
    DROP COLUMN `emailTo`,
    DROP COLUMN `emailCC`;

DELETE FROM `email_templates` WHERE body = 'LEAF_main_email_template.tpl';

COMMIT;

*/