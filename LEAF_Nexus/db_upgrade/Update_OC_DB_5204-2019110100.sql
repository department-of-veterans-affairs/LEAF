START TRANSACTION;

CREATE TABLE `data_action_log` (
  `empUID` varchar(36) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` varchar(45) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `timestamp` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `data_log_items` (
  `data_action_log_fk` int(11) NOT NULL,
  `tableName` varchar(75) NOT NULL,
  `column` varchar(75) NOT NULL,
  `value` varchar(75) NOT NULL,
  `displayValue` varchar(256),
  PRIMARY KEY (`data_action_log_fk`,`tableName`,`column`)
);


UPDATE `settings` SET `data` = '2019110100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
