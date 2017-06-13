START TRANSACTION;

ALTER TABLE `records` CHANGE `lastStatus` `lastStatus` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ;

UPDATE `settings` SET `data` = '3135' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
