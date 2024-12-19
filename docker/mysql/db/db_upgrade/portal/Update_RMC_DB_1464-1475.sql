START TRANSACTION;
CREATE TABLE IF NOT EXISTS `events` (`eventID` VARCHAR(20) NOT NULL, `eventDescription` VARCHAR(64) NOT NULL, `event` INT(64) NOT NULL) ENGINE = InnoDB;
ALTER TABLE `events` ADD PRIMARY KEY(`eventID`);
ALTER TABLE `events` CHANGE `event` `event` VARCHAR(64) NOT NULL;
INSERT INTO `events` (`eventID`, `eventDescription`, `event`) VALUES ('std_email_notify', 'Standard Email Notification', '');

CREATE TABLE IF NOT EXISTS `route_events` (`workflowID` TINYINT UNSIGNED NOT NULL, `stepID` TINYINT UNSIGNED NOT NULL, `eventID` VARCHAR(20) NOT NULL) ENGINE = InnoDB;
ALTER TABLE `route_events` ADD INDEX( `workflowID`, `stepID`);
ALTER TABLE `route_events` ADD INDEX(`eventID`);
ALTER TABLE `route_events` ADD FOREIGN KEY (`eventID`) REFERENCES `events`(`eventID`);
ALTER TABLE `route_events`  ADD `actionType` VARCHAR(20) NOT NULL AFTER `stepID`;
ALTER TABLE `route_events` DROP INDEX `workflowID`, ADD INDEX `workflowID` (`workflowID`, `stepID`, `actionType`);
ALTER TABLE `route_events` ADD INDEX(`actionType`);
ALTER TABLE `route_events` ADD FOREIGN KEY (`actionType`) REFERENCES `actions`(`actionType`);


UPDATE `settings` SET `data` = '1475' WHERE `settings`.`setting` = 'dbversion';
COMMIT;