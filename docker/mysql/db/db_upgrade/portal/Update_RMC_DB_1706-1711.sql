START TRANSACTION;
ALTER TABLE `action_history` CHANGE `comment` `comment` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;

UPDATE `settings` SET `data` = '1711' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
