START TRANSACTION;

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES ('26', 'HR Smart Position Number', 'number', NULL, NULL, NULL, 'position', NULL, NULL, '1', '6', CURRENT_TIMESTAMP, '0', '0');

UPDATE `settings` SET `data` = '4900' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
