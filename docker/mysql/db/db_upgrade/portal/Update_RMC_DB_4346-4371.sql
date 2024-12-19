START TRANSACTION;

INSERT INTO `dependencies` (`dependencyID`, `description`) VALUES ('-1', 'Person Designated by the Requestor');
ALTER TABLE `workflow_steps` ADD `indicatorID_for_assigned_empUID` SMALLINT NULL DEFAULT NULL AFTER `posY`;
ALTER TABLE `action_history` CHANGE `dependencyID` `dependencyID` TINYINT(3) NOT NULL;

UPDATE `settings` SET `data` = '4371' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
