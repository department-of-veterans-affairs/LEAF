START TRANSACTION;

ALTER TABLE action_history DROP groupID;
ALTER TABLE `action_history` ADD `stepID` SMALLINT NOT NULL AFTER `userID`;
ALTER TABLE `action_history` CHANGE `stepID` `stepID` SMALLINT(6) NOT NULL DEFAULT '0';

UPDATE `settings` SET `data` = '5164' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
