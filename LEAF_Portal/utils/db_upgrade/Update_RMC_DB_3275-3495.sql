START TRANSACTION;

ALTER TABLE `data` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;
ALTER TABLE `data_history` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;
ALTER TABLE `indicators` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL AUTO_INCREMENT ;
ALTER TABLE `indicator_mask` CHANGE `indicatorID` `indicatorID` SMALLINT( 5 ) NOT NULL ;

UPDATE `settings` SET `data` = '3495' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
