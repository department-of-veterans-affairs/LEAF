START TRANSACTION;

UPDATE `email_templates` SET `subject` = 'LEAF_notify_complete_subject.tpl', `body` = 'LEAF_notify_complete_body.tpl' WHERE `emailTemplateID` = -3;
UPDATE `email_templates` SET `subject` = 'LEAF_notify_next_subject.tpl', `body` = 'LEAF_notify_next_body.tpl' WHERE `emailTemplateID` = -2;
UPDATE `email_templates` SET `subject` = 'LEAF_send_back_subject.tpl',	`body` = 'LEAF_send_back_body.tpl' WHERE `emailTemplateID` = -1;

UPDATE `settings` SET `data` = '2020041300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;