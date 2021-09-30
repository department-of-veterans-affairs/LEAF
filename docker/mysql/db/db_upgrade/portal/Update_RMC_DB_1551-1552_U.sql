START TRANSACTION;
-- This update potentially breaks compatibility with older software versions
ALTER TABLE `records_workflow_state` ADD `blockingStepID` TINYINT NOT NULL DEFAULT '0';
ALTER TABLE `action_history` ADD INDEX ( `dependencyID` );
ALTER TABLE `action_history` ADD INDEX ( `actionType` );

ALTER TABLE `records` DROP `numSpace`, DROP `numEquipment`, DROP `numFTE`, DROP `numFurniture`, DROP `numIT`, DROP `numFCP`;

UPDATE `settings` SET `data` = '1552' WHERE `settings`.`setting` = 'dbversion';
COMMIT;