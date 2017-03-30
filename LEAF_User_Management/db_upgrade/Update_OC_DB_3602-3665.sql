START TRANSACTION;

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES (22, 'Organization Code', 'text', NULL, NULL, NULL, 'position', NULL, NULL, '0', '1', CURRENT_TIMESTAMP, '0', '0');
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` = 22;
UPDATE `indicators` SET `sort` = '20' WHERE `indicators`.`indicatorID` = 22;

UPDATE `settings` SET `data` = '3665' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
