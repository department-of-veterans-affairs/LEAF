START TRANSACTION;

ALTER TABLE `events` ADD COLUMN `eventType` varchar(40) NOT NULL AFTER `eventDescription`;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_2`;
ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

UPDATE `events` SET `eventType` = 'Email' WHERE `eventID` = 'std_email_notify_completed' OR `eventID` = 'std_email_notify_next_approver';
UPDATE `events` SET `eventDescription` = 'Notify the requestor' WHERE `eventID` = 'std_email_notify_completed';
UPDATE `events` SET `eventDescription` = 'Notify the next approver' WHERE `eventID` = 'std_email_notify_next_approver';

UPDATE `settings` SET `data` = '2021091600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

DELETE FROM `events` WHERE eventID LIKE "CustomEvent_%";
DELETE FROM `email_templates` WHERE emailTemplateID > 1;

ALTER TABLE `events` DROP COLUMN `eventType`;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_2`;
ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`);

UPDATE `events` SET eventDescription='Notify the requestor via email' WHERE eventID='std_email_notify_completed';
UPDATE `events` SET eventDescription='Notify the next approver via email' WHERE eventID='std_email_notify_next_approver';

UPDATE `settings` SET `data` = '2021062800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
