START TRANSACTION;

ALTER TABLE `events` ADD COLUMN `eventType` varchar(40) NOT NULL AFTER `eventDescription`;

UPDATE `events` SET eventType='Email' WHERE eventID='std_email_notify_completed' OR eventID='std_email_notify_next_approver';
UPDATE `events` SET eventDescription='Notify the requestor' WHERE eventID='std_email_notify_completed';
UPDATE `events` SET eventDescription='Notify the next approver' WHERE eventID='std_email_notify_next_approver';

UPDATE `settings` SET `data` = '2021091400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `events` DROP COLUMN `eventType`;

UPDATE `events` SET eventDescription='Notify the requestor via email' WHERE eventID='std_email_notify_completed';
UPDATE `events` SET eventDescription='Notify the next approver via email' WHERE eventID='std_email_notify_next_approver';

UPDATE `settings` SET `data` = '2021062800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/