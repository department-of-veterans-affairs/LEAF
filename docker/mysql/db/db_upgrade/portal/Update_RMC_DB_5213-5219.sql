START TRANSACTION;

ALTER TABLE `records_workflow_state` CHANGE `recordID` `recordID` SMALLINT(6) UNSIGNED NOT NULL;

UPDATE `settings` SET `data` = '5219' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
