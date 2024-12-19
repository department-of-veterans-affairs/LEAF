START TRANSACTION;

ALTER TABLE `workflow_steps` ADD `indicatorID_for_assigned_groupID` SMALLINT NULL DEFAULT NULL AFTER `indicatorID_for_assigned_empUID`;
INSERT INTO `dependencies` (`dependencyID`, `description`) VALUES ('-3', 'Group Designated by the Requestor');

UPDATE `settings` SET `data` = '4968' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
