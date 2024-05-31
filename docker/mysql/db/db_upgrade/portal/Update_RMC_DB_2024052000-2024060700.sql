START TRANSACTION;

INSERT INTO `email_templates` (`emailTemplateID`, `label`, `emailTo`, `emailCc`, `subject`, `body`)
VALUES ('-7', 'Cancel Notification', 'LEAF_cancel_notification_emailTo.tpl', 'LEAF_cancel_notification_emailCc.tpl', 'LEAF_cancel_notification_subject.tpl', 'LEAF_cancel_notification_body.tpl');

UPDATE `settings` SET `data` = '2024060700' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DELETE FROM `email_templates` WHERE `emailTemplateID` = -7;

 UPDATE `settings` SET `data` = '2024052000' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */
