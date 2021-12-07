START TRANSACTION;

ALTER TABLE `workflow_routes` CHANGE `actionType` `actionType` VARCHAR( 50 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL ;
ALTER TABLE `route_events` CHANGE `actionType` `actionType` VARCHAR( 50 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;
ALTER TABLE `workflow_routes` ADD `displayConditional` TEXT NOT NULL ;

UPDATE `settings` SET `data` = '3133' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
