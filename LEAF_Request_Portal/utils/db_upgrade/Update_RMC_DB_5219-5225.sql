START TRANSACTION;

ALTER TABLE `records_workflow_state` CHANGE `stepID` `stepID` SMALLINT UNSIGNED NOT NULL;
ALTER TABLE `workflow_routes` CHANGE `nextStepID` `nextStepID` SMALLINT UNSIGNED NOT NULL;

UPDATE `settings` SET `data` = '5225' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
