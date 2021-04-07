START TRANSACTION;

ALTER TABLE `users` ADD COLUMN `backupID` VARCHAR(50) NULL AFTER `groupID`;
ALTER TABLE `service_chiefs` ADD COLUMN `backupID` VARCHAR(50) NULL AFTER `userID`;

UPDATE `settings` SET `data` = '2021040500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `users` DROP COLUMN `backupID`;
ALTER TABLE `service_chiefs` DROP COLUMN `backupID`;

COMMIT;

*/