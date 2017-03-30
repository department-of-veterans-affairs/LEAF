START TRANSACTION;

CREATE TABLE IF NOT EXISTS `relation_employee_backup` (
  `empUID` smallint(5) unsigned NOT NULL,
  `backupEmpUID` smallint(5) unsigned NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT '0',
  `approverUserName` varchar(30) DEFAULT NULL,
  UNIQUE KEY `empUID` (`empUID`,`backupEmpUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE `settings` SET `data` = '3520' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
