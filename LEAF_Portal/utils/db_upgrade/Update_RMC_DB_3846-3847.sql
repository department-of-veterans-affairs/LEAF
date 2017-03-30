START TRANSACTION;

ALTER TABLE `indicators` ADD `htmlPrint` TEXT NOT NULL AFTER `html`;
ALTER TABLE `indicators` CHANGE `htmlPrint` `htmlPrint` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;

UPDATE `settings` SET `data` = '3847' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
