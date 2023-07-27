START TRANSACTION;

UPDATE `users`
SET `backupID` = ""
WHERE `backupID` IS NULL;

ALTER TABLE `users` MODIFY `backupID` varchar(50) NOT NULL DEFAULT '';

ALTER TABLE `users` DROP PRIMARY KEY;

ALTER TABLE `users` ADD PRIMARY KEY(`userID`, `groupID`, `backupID`);

UPDATE `settings` SET `data` = '2023072000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 ALTER TABLE `users` DROP PRIMARY KEY;

ALTER TABLE `users` ADD PRIMARY KEY(`userID`, `groupID`);

ALTER TABLE `users` MODIFY `backupID` varchar(50);

UPDATE `users`
SET `backupID` = NULL
WHERE `backupID` = "";

 UPDATE `settings` SET `data` = '2023052500' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */