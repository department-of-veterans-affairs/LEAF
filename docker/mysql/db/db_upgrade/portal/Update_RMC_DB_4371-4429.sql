START TRANSACTION;

ALTER TABLE `groups` CHANGE `name` `name` VARCHAR(250) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL;

UPDATE `settings` SET `data` = '4429' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
