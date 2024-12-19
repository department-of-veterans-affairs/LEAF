START TRANSACTION;

ALTER TABLE `indicators` CHANGE `html` `html` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;

UPDATE `settings` SET `data` = '4291' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
