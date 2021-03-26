START TRANSACTION;

ALTER TABLE `users` ADD `backupID` VARCHAR(50) NULL AFTER `groupID`;
ALTER TABLE `service_chiefs` ADD `backupID` VARCHAR(50) NULL AFTER `userID`;


UPDATE `settings` SET `data` = '2021040500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
