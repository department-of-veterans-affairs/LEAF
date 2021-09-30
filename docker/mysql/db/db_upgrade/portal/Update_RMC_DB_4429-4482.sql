START TRANSACTION;

INSERT INTO `dependencies` (`dependencyID`, `description`) VALUES ('-2', 'Requestor Followup');
CREATE TABLE IF NOT EXISTS `data_extended` (
  `recordID` smallint unsigned NOT NULL,
  `indicatorID` smallint NOT NULL,
  `data` text NOT NULL,
  `timestamp` int unsigned NOT NULL,
  `userID` varchar(50) NOT NULL
) ENGINE='InnoDB';
ALTER TABLE `data_extended`
ADD INDEX `recordID_indicatorID` (`recordID`, `indicatorID`);

DROP TABLE `service_data`;
DROP TABLE `service_data_history`;
DROP TABLE `pair_category_serviceiid`;
DROP TABLE `service_indicatorid`;

UPDATE `settings` SET `data` = '4482' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
