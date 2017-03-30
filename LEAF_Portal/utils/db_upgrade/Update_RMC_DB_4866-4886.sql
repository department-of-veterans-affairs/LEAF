START TRANSACTION;

ALTER TABLE `indicators` CHANGE `default` `default` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;

UPDATE `settings` SET `data` = '4886' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
