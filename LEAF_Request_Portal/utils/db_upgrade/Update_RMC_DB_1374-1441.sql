START TRANSACTION;
ALTER TABLE `dependencies` CHANGE `dependencyID` `dependencyID` TINYINT(4) UNSIGNED NOT NULL AUTO_INCREMENT;

CREATE TABLE IF NOT EXISTS`workflows` (`workflowID` TINYINT NOT NULL, `description` VARCHAR(64) NOT NULL, PRIMARY KEY (`workflowID`)) ENGINE = InnoDB;
ALTER TABLE `workflows` CHANGE `workflowID` `workflowID` TINYINT(4) UNSIGNED NOT NULL;
ALTER TABLE `workflows` CHANGE `workflowID` `workflowID` TINYINT(4) UNSIGNED NOT NULL AUTO_INCREMENT;
ALTER TABLE `workflows`  ADD `initialStepID` TINYINT UNSIGNED NOT NULL AFTER `workflowID`;

CREATE TABLE IF NOT EXISTS`dependency_privs` (`dependencyID` TINYINT UNSIGNED NOT NULL, `groupID` TINYINT UNSIGNED NOT NULL) ENGINE = InnoDB;

ALTER TABLE `dependency_privs` ADD UNIQUE( `dependencyID`, `groupID`);

ALTER TABLE `dependency_privs` ADD FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`);
ALTER TABLE `dependency_privs` ADD FOREIGN KEY (`groupID`) REFERENCES `groups`(`groupID`);

CREATE TABLE IF NOT EXISTS `workflow_steps` (`workflowID` TINYINT NOT NULL, `stepID` TINYINT NOT NULL, `actions` VARCHAR(128) NOT NULL, `route` TEXT NOT NULL, PRIMARY KEY (`stepID`)) ENGINE = InnoDB;
ALTER TABLE `workflow_steps`  ADD `stepDesc` VARCHAR(64) NOT NULL AFTER `stepID`;
ALTER TABLE `workflow_steps` CHANGE `workflowID` `workflowID` TINYINT(4) UNSIGNED NOT NULL;
ALTER TABLE `workflow_steps` CHANGE `stepID` `stepID` TINYINT(4) UNSIGNED NOT NULL;
ALTER TABLE `workflow_steps` ADD INDEX(`workflowID`);
ALTER TABLE `workflow_steps` ADD FOREIGN KEY (`workflowID`) REFERENCES `workflows`(`workflowID`);
ALTER TABLE `workflow_steps` CHANGE `stepDesc` `stepTitle` VARCHAR(64) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;
ALTER TABLE `workflow_steps` CHANGE `stepID` `stepID` TINYINT(4) UNSIGNED NOT NULL AUTO_INCREMENT;
ALTER TABLE `workflow_steps`  ADD `stepBgColor` VARCHAR(10) NOT NULL,  ADD `stepFontColor` VARCHAR(10) NOT NULL;
ALTER TABLE `workflow_steps`  ADD `stepBorder` VARCHAR(20) NOT NULL;

CREATE TABLE IF NOT EXISTS `step_dependencies` (`stepID` TINYINT NOT NULL, `dependencyID` TINYINT NOT NULL) ENGINE = InnoDB;
ALTER TABLE `step_dependencies` ADD UNIQUE( `stepID`, `dependencyID`);
ALTER TABLE `step_dependencies` CHANGE `stepID` `stepID` TINYINT(4) UNSIGNED NOT NULL;
ALTER TABLE `step_dependencies` ADD FOREIGN KEY (`stepID`) REFERENCES `workflow_steps`(`stepID`);
ALTER TABLE `step_dependencies` CHANGE `dependencyID` `dependencyID` TINYINT(4) UNSIGNED NOT NULL;
ALTER TABLE `step_dependencies` ADD FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`);

CREATE TABLE IF NOT EXISTS `actions` (`actionType` VARCHAR(20) NOT NULL, `actionText` VARCHAR(20) NOT NULL, `actionIcon` VARCHAR(50) NOT NULL, `actionAlignment` VARCHAR(10) NOT NULL, PRIMARY KEY (`actionType`)) ENGINE = InnoDB;
INSERT INTO `actions` (`actionType`, `actionText`, `actionIcon`, `actionAlignment`) VALUES ('approve', 'Approve', 'go-next.svg', 'right'), ('disapprove', 'Disapprove', 'process-stop.svg', 'left'), ('defer', 'Defer', 'software-update-urgent.svg', 'left'), ('sendback', 'Send Back', 'edit-undo.svg', 'left');
INSERT INTO `actions` (`actionType`, `actionText`, `actionIcon`, `actionAlignment`) VALUES ('concur', 'Concur', 'go-next.svg', 'right');

CREATE TABLE IF NOT EXISTS `records_workflow_state` (`recordID` SMALLINT NOT NULL, `stepID` TINYINT NOT NULL) ENGINE = InnoDB;
ALTER TABLE `records_workflow_state` ADD UNIQUE( `recordID`, `stepID`);

ALTER TABLE `categories`  ADD `workflowID` TINYINT UNSIGNED NOT NULL AFTER `categoryDescription`;

CREATE TABLE IF NOT EXISTS `step_actions` (`stepID` TINYINT UNSIGNED NOT NULL, `actionType` VARCHAR(20) NOT NULL) ENGINE = InnoDB;
ALTER TABLE `step_actions` ADD UNIQUE( `stepID`, `actionType`);

ALTER TABLE `workflow_steps` DROP `actions`;
ALTER TABLE `step_actions` ADD FOREIGN KEY (`stepID`) REFERENCES `workflow_steps`(`stepID`);
ALTER TABLE `step_actions` ADD FOREIGN KEY (`actionType`) REFERENCES `actions`(`actionType`);

ALTER TABLE `actions`  ADD `sort` TINYINT NOT NULL;
ALTER TABLE `actions` CHANGE `actionAlignment` `actionAlignment` VARCHAR(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;

CREATE TABLE `dependency_actions` (`dependencyID` TINYINT UNSIGNED NOT NULL, `actionType` VARCHAR(20) NOT NULL) ENGINE = InnoDB;
ALTER TABLE `dependency_actions` ADD UNIQUE( `dependencyID`, `actionType`);
ALTER TABLE `dependency_actions` ADD FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`);
ALTER TABLE `dependency_actions` ADD FOREIGN KEY (`actionType`) REFERENCES `actions`(`actionType`);

DROP TABLE `step_actions`;

CREATE TABLE IF NOT EXISTS `workflow_routes` (`workflowID` TINYINT UNSIGNED NOT NULL, `stepID` TINYINT UNSIGNED NOT NULL, `nextStepID` TINYINT UNSIGNED NOT NULL, `actionType` VARCHAR(20) NOT NULL, `fillDependency` TINYINT NOT NULL) ENGINE = InnoDB;
ALTER TABLE `workflow_routes` ADD UNIQUE( `workflowID`, `stepID`, `actionType`);
ALTER TABLE `workflow_routes` ADD FOREIGN KEY (`workflowID`) REFERENCES `workflows`(`workflowID`);
ALTER TABLE `workflow_routes` ADD FOREIGN KEY (`stepID`) REFERENCES `workflow_steps`(`stepID`);
ALTER TABLE `workflow_routes` ADD FOREIGN KEY (`actionType`) REFERENCES `actions`(`actionType`);

ALTER TABLE `action_history`  ADD `actionType` VARCHAR(20) NOT NULL AFTER `groupID`;
ALTER TABLE `workflow_steps` DROP `route`;
ALTER TABLE `workflows` CHANGE `initialStepID` `initialStepID` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0';
ALTER TABLE `workflow_steps` CHANGE `stepBgColor` `stepBgColor` VARCHAR(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '#fffdcd', CHANGE `stepFontColor` `stepFontColor` VARCHAR(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL, CHANGE `stepBorder` `stepBorder` VARCHAR(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;
ALTER TABLE `workflow_steps` CHANGE `stepFontColor` `stepFontColor` VARCHAR(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'black', CHANGE `stepBorder` `stepBorder` VARCHAR(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;
ALTER TABLE `workflow_steps` CHANGE `stepBorder` `stepBorder` VARCHAR(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '1px solid black';

INSERT INTO `settings` (`setting`, `data`) VALUES ('dbversion', '1441');
COMMIT;