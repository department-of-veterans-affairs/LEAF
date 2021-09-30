START TRANSACTION;

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES ('23', 'AD Title', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, '0', '1', CURRENT_TIMESTAMP, '0', '0');

UPDATE `settings` SET `data` = '4232' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
