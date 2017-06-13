START TRANSACTION;

ALTER TABLE workflow_routes DROP FOREIGN KEY workflow_routes_ibfk_4;

ALTER TABLE `workflows` CHANGE `initialStepID` `initialStepID` SMALLINT NOT NULL DEFAULT '0';

ALTER TABLE `route_events` CHANGE `stepID` `stepID` SMALLINT NOT NULL;

UPDATE `route_events` SET stepID=-1 WHERE stepID=0;

UPDATE `settings` SET `data` = '5150' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
