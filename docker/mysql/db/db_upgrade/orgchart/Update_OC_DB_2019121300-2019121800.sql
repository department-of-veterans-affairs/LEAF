START TRANSACTION;

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES ('27', 'LEAF Developer Console Access', 'checkbox\r\nYes', NULL, NULL, NULL, 'employee', NULL, NULL, '0', '98', current_timestamp(), '0', '0'), ('28', 'LEAF Developer Console Request Reference', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, '0', '99', current_timestamp(), '0', '0'); 
INSERT INTO `indicator_privileges` (`indicatorID`, `categoryID`, `UID`, `read`, `write`, `grant`) VALUES
(27, 'group', 2, 1, 0, 0),
(28, 'group', 2, 1, 0, 0);

UPDATE `settings` SET `data` = '2019121800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
