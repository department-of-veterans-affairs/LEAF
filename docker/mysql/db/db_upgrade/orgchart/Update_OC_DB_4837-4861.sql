START TRANSACTION;

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES (24, 'Contact Info', 'text', NULL, NULL, NULL, 'group', NULL, NULL, '1', '1', CURRENT_TIMESTAMP, '0', '0');
INSERT INTO `indicator_privileges` (`indicatorID`, `categoryID`, `UID`, `read`, `write`, `grant`) VALUES ('24', 'group', '1', '1', '1', '1'), ('24', 'group', '2', '1', '0', '0');

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES ('25', 'Location', 'text', NULL, NULL, NULL, 'group', NULL, NULL, '1', '1', CURRENT_TIMESTAMP, '0', '0');
INSERT INTO `indicator_privileges` (`indicatorID`, `categoryID`, `UID`, `read`, `write`, `grant`) VALUES ('25', 'group', '1', '1', '1', '1'), ('25', 'group', '2', '1', '0', '0');

UPDATE `settings` SET `data` = '4861' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
