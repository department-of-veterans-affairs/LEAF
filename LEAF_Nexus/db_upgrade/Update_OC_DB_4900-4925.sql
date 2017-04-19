START TRANSACTION;

ALTER TABLE `groups` CHANGE `groupAbbreviation` `groupAbbreviation` VARCHAR(250) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;

UPDATE `settings` SET `data` = '4925' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
