START TRANSACTION;

CREATE TABLE `email_tracker` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recordID` mediumint(8) unsigned NOT NULL,
  `userID` varchar(50) DEFAULT NULL,
  `timestamp` int(10) NOT NULL,
  `recipients` text NOT NULL,
  `subject` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `recordID` (`recordID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 UPDATE `settings` SET `data` = '2023052500' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DROP TABLE IF EXISTS `email_tracker`;
 UPDATE `settings` SET `data` = '2023040700' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */