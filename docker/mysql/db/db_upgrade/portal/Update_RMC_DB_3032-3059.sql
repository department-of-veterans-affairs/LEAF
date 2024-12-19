START TRANSACTION;

ALTER TABLE `approvals` CHANGE `groupID` `groupID` MEDIUMINT NOT NULL DEFAULT '0';
ALTER TABLE `category_privs` CHANGE `groupID` `groupID` MEDIUMINT NOT NULL ;
ALTER TABLE `dependency_privs` CHANGE `groupID` `groupID` MEDIUMINT NOT NULL ;
ALTER TABLE `groups` CHANGE `groupID` `groupID` MEDIUMINT NOT NULL AUTO_INCREMENT ;
ALTER TABLE `indicator_mask` CHANGE `groupID` `groupID` MEDIUMINT NOT NULL ;
ALTER TABLE `services` CHANGE `groupID` `groupID` MEDIUMINT NULL DEFAULT NULL ;
ALTER TABLE `records` CHANGE `serviceID` `serviceID` SMALLINT UNSIGNED NOT NULL DEFAULT '0';
ALTER TABLE `services` CHANGE `serviceID` `serviceID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT ;
ALTER TABLE `service_chiefs` CHANGE `serviceID` `serviceID` SMALLINT UNSIGNED NOT NULL ;
ALTER TABLE `service_data` CHANGE `serviceID` `serviceID` SMALLINT UNSIGNED NOT NULL ;
ALTER TABLE `service_data_history` CHANGE `serviceID` `serviceID` SMALLINT UNSIGNED NOT NULL ;
ALTER TABLE `users` CHANGE `groupID` `groupID` SMALLINT UNSIGNED NOT NULL ;


UPDATE `settings` SET `data` = '3059' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
