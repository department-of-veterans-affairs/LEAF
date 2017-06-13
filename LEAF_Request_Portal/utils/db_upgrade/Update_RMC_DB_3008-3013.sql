START TRANSACTION;

ALTER TABLE `approvals` DROP FOREIGN KEY `approvals_ibfk_1` ;
ALTER TABLE `category_privs` DROP FOREIGN KEY `category_privs_ibfk_1` ;
ALTER TABLE `dependency_privs` DROP FOREIGN KEY `dependency_privs_ibfk_2` ;
ALTER TABLE `indicator_mask` DROP FOREIGN KEY `indicator_mask_ibfk_2` ;
ALTER TABLE `users` DROP FOREIGN KEY `users_ibfk_1` ;
ALTER TABLE `groups` CHANGE `groupID` `groupID` TINYINT( 3 ) NOT NULL AUTO_INCREMENT;
ALTER TABLE `groups` CHANGE `groupDescription` `groupDescription` VARCHAR( 50 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '';

UPDATE `settings` SET `data` = '3013' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
