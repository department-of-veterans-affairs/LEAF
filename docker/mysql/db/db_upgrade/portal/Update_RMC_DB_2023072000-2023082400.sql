START TRANSACTION;

UPDATE `service_chiefs`
SET `backupID` = ""
WHERE `backupID` IS NULL;

ALTER TABLE `service_chiefs` MODIFY `backupID` varchar(50) NOT NULL DEFAULT '';

ALTER TABLE `service_chiefs` DROP INDEX `serviceID_2`;

ALTER TABLE `service_chiefs` ADD PRIMARY KEY(`userID`, `serviceID`, `backupID`);

UPDATE `settings` SET `data` = '2023082400' WHERE `settings`.`setting` = 'dbversion';

/* This cannot be reverted */
DELETE FROM `dependency_privs` WHERE `groupID` NOT IN (SELECT `groupID` FROM `groups`);

COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 ALTER TABLE `service_chiefs` DROP PRIMARY KEY;

ALTER TABLE `service_chiefs` ADD PRIMARY KEY(`userID`, `groupID`);

ALTER TABLE `service_chiefs` MODIFY `backupID` varchar(50);

UPDATE `service_chiefs`
SET `backupID` = NULL
WHERE `backupID` = "";

 UPDATE `settings` SET `data` = '2023072000' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */