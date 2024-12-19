START TRANSACTION;

INSERT INTO `email_templates` (emailTemplateID, label, emailTo, emailCc, subject, body)
VALUES (-4, 'Mass Action Email Reminder Template', 'LEAF_mass_action_remind_emailTo.tpl', 'LEAF_mass_action_remind_emailCc.tpl', 'LEAF_mass_action_remind_subject.tpl', 'LEAF_mass_action_remind_body.tpl');

UPDATE `settings` SET `data` = '2021062800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

DELETE FROM `email_templates` WHERE emailTemplateID = -4;

UPDATE `settings` SET `data` = '2021041900' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/