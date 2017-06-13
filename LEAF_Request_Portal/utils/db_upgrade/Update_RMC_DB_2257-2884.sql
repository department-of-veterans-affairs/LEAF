START TRANSACTION;
ALTER TABLE `records_workflow_state` CHANGE `stepID` `stepID` TINYINT( 4 ) UNSIGNED NOT NULL ,
CHANGE `blockingStepID` `blockingStepID` TINYINT( 4 ) UNSIGNED NOT NULL DEFAULT '0';

UPDATE `settings` SET `data` = '2884' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
