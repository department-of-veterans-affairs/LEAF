START TRANSACTION;

ALTER TABLE `records` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT;
ALTER TABLE `records_dependencies` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `records_step_fulfillment` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `records_workflow_state` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `action_history` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `approvals` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `category_count` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `data` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `data_extended` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;
ALTER TABLE `data_history` CHANGE `recordID` `recordID` MEDIUMINT UNSIGNED NOT NULL;

UPDATE `settings` SET `data` = '2019080600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
