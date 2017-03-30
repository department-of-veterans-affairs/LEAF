START TRANSACTION;

INSERT IGNORE INTO `indicator_privileges` (`indicatorID`, `categoryID`, `UID`, `read`, `write`, `grant`) VALUES ('23', 'group', '1', '1', '1', '1'), ('23', 'group', '2', '1', '0', '0');

UPDATE `settings` SET `data` = '4977' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
