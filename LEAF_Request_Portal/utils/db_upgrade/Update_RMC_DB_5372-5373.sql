START TRANSACTION;

DROP TABLE IF EXISTS `workflow_conditions`;
CREATE TABLE `workflow_conditions` (
  `workflowConditionID` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `workflowConditionSetID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) unsigned NOT NULL,
  `comparator` enum('===','!==','>','>=','<','<=') NOT NULL,
  `targetValue` text NOT NULL,
  `targetValueType` enum('int','string','daysSinceSubmit') DEFAULT NULL,
  PRIMARY KEY (`workflowConditionID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `workflow_condition_sets`;
CREATE TABLE `workflow_condition_sets` (
  `workflowConditionSetID` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `fromStepID` smallint(5) unsigned NOT NULL,
  `toStepID` smallint(5) unsigned NOT NULL,
  `precedence` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`workflowConditionSetID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

INSERT INTO `actions` 
(`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`, `deleted`) 
VALUES
('conditional',	'Conditional',	'Conditional Chosen',	'go-next.svg',	'right',	0,	1,	0);

UPDATE `settings` SET `data` = '5373' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
