START TRANSACTION;

ALTER TABLE `step_dependencies` DROP FOREIGN KEY `step_dependencies_ibfk_1`;
ALTER TABLE `step_dependencies` CHANGE `stepID` `stepID` SMALLINT NOT NULL;
ALTER TABLE `workflow_routes` DROP FOREIGN KEY `workflow_routes_ibfk_2`;
ALTER TABLE `workflow_routes` CHANGE `stepID` `stepID` SMALLINT NOT NULL;
ALTER TABLE `workflow_steps` CHANGE `stepID` `stepID` SMALLINT NOT NULL AUTO_INCREMENT;
ALTER TABLE `workflow_routes` ADD FOREIGN KEY (`stepID`) REFERENCES `workflow_steps`(`stepID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `step_dependencies` ADD FOREIGN KEY (`stepID`) REFERENCES `workflow_steps`(`stepID`) ON DELETE RESTRICT ON UPDATE RESTRICT;

INSERT INTO `actions` (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`) VALUES ('submit', 'Submit', 'Submitted', 'gnome-emblem-default.svg', 'right', '0', '1');

ALTER TABLE `category_dependencies` DROP FOREIGN KEY `category_dependencies_ibfk_2`;
ALTER TABLE `category_dependencies` CHANGE `dependencyID` `dependencyID` SMALLINT NOT NULL;
ALTER TABLE `dependency_privs` DROP FOREIGN KEY `dependency_privs_ibfk_1`;
ALTER TABLE `dependency_privs` CHANGE `dependencyID` `dependencyID` SMALLINT NOT NULL;
ALTER TABLE `records_dependencies` DROP FOREIGN KEY `records_dependencies_ibfk_2`;
ALTER TABLE `records_dependencies` CHANGE `dependencyID` `dependencyID` SMALLINT NOT NULL;
ALTER TABLE `step_dependencies` DROP FOREIGN KEY `step_dependencies_ibfk_2`;
ALTER TABLE `step_dependencies` CHANGE `dependencyID` `dependencyID` SMALLINT NOT NULL;
ALTER TABLE `dependencies` CHANGE `dependencyID` `dependencyID` SMALLINT NOT NULL AUTO_INCREMENT;
ALTER TABLE `category_dependencies` ADD CONSTRAINT `fk_category_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `dependency_privs` ADD CONSTRAINT `fk_privs_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `records_dependencies` ADD CONSTRAINT `fk_records_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `step_dependencies` ADD CONSTRAINT `fk_step_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies`(`dependencyID`) ON DELETE RESTRICT ON UPDATE RESTRICT;


UPDATE `settings` SET `data` = '3842' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
