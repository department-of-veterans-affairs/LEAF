START TRANSACTION;

CREATE TABLE `step_modules` (
  `stepID` smallint(6) NOT NULL,
  `moduleName` varchar(50) NOT NULL,
  `moduleConfig` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
ALTER TABLE `step_modules` ADD UNIQUE `stepID_moduleName` (`stepID`, `moduleName`);

UPDATE `settings` SET `data` = '5360' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
