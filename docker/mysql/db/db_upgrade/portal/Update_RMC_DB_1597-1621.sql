-- route_events must be cleared of any standard action types first
START TRANSACTION;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_2`;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_1`;

ALTER TABLE `events` CHANGE `eventID` `eventID` VARCHAR( 40 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;
ALTER TABLE `route_events` CHANGE `eventID` `eventID` VARCHAR( 40 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;

UPDATE `events` SET `eventID` = 'std_email_notify_next_approver' WHERE `events`.`eventID` = 'std_email_notify';
UPDATE `events` SET `eventDescription` = 'Standard Email Notification for next approver' WHERE `events`.`eventID` = 'std_email_notify_next_approver';
INSERT INTO `events` (`eventID`, `eventDescription`, `event`) VALUES ('std_email_notify_completed', 'Standard notification alerting requestor of approved request', '');

ALTER TABLE `events` CHANGE `eventDescription` `eventDescription` VARCHAR( 200 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;
ALTER TABLE `route_events` ADD FOREIGN KEY (`actionType`) REFERENCES `actions`(`actionType`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `route_events` ADD FOREIGN KEY (`eventID`) REFERENCES `events`(`eventID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

UPDATE `settings` SET `data` = '1621' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
