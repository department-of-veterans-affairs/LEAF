START TRANSACTION;

ALTER TABLE `action_history` CHANGE `actionType` `actionType` VARCHAR( 50 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ;

UPDATE `settings` SET `data` = '3134' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
