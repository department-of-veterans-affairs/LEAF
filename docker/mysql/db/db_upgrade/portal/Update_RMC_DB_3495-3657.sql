START TRANSACTION;

ALTER TABLE `users` CHANGE `groupID` `groupID` SMALLINT(5) NOT NULL;
ALTER TABLE `users` CHANGE `groupID` `groupID` MEDIUMINT NOT NULL;

UPDATE `settings` SET `data` = '3657' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
