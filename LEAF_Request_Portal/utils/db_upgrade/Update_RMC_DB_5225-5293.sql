START TRANSACTION;

ALTER TABLE `action_history` CHANGE `dependencyID` `dependencyID` SMALLINT NOT NULL;

UPDATE `settings` SET `data` = '5293' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
