START TRANSACTION;
CREATE TABLE IF NOT EXISTS `sessions` (
  `sessionKey` varchar(40) NOT NULL,
  `variableKey` varchar(40) NOT NULL DEFAULT '',
  `data` text NOT NULL,
  `lastModified` int(10) unsigned NOT NULL,
  UNIQUE KEY `sessionKey` (`sessionKey`,`variableKey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

UPDATE `settings` SET `data` = '2945' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
