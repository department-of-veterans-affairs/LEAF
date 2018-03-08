START TRANSACTION;

CREATE TABLE IF NOT EXISTS `records_step_fulfillment` (
  `recordID` smallint(5) UNSIGNED NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `fulfillmentTime` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `records_step_fulfillment`
  ADD UNIQUE KEY `recordID` (`recordID`,`stepID`) USING BTREE;

UPDATE `settings` SET `data` = '5099' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
