START TRANSACTION;

ALTER TABLE `categories` ADD `formLibraryID` SMALLINT NULL DEFAULT NULL AFTER `needToKnow`;

UPDATE `settings` SET `data` = '4985' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
