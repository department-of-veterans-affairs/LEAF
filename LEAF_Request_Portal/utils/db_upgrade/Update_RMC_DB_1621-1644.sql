START TRANSACTION;
ALTER TABLE `indicators` CHANGE `html` `html` VARCHAR( 510 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;

UPDATE `settings` SET `data` = '1644' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
