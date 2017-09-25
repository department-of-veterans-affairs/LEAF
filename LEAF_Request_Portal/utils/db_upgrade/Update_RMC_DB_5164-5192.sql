START TRANSACTION;

ALTER TABLE `categories` ADD `visible` TINYINT NOT NULL DEFAULT '1' AFTER `formLibraryID`;

UPDATE `settings` SET `data` = '5192' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
