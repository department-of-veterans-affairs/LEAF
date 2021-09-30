START TRANSACTION;

ALTER TABLE `employee_data` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;
ALTER TABLE `employee_data_history` CHANGE `indicatorID` `indicatorID` TINYINT( 3 ) NOT NULL ;
ALTER TABLE `group_data` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;
ALTER TABLE `group_data_history` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;
ALTER TABLE `indicators` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL AUTO_INCREMENT ;
ALTER TABLE `indicator_privileges` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;
ALTER TABLE `position_data` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;
ALTER TABLE `position_data_history` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;

UPDATE `settings` SET `data` = '3495' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
