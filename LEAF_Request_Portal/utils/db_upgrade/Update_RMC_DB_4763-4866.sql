START TRANSACTION;

ALTER TABLE `service_chiefs` ADD `locallyManaged` TINYINT(1) NULL AFTER `userID`;

ALTER TABLE `services` CHANGE `serviceID` `serviceID` SMALLINT(5) NOT NULL AUTO_INCREMENT;
ALTER TABLE `service_chiefs` CHANGE `serviceID` `serviceID` SMALLINT(5) NOT NULL;
ALTER TABLE `records` CHANGE `serviceID` `serviceID` SMALLINT(5) NOT NULL DEFAULT '0';

UPDATE `settings` SET `data` = '4866' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
