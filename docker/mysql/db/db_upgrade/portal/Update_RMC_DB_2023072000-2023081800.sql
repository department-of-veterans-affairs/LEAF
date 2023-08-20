START TRANSACTION;

CREATE TABLE `template_designs` (
  `designID` int(11) NOT NULL AUTO_INCREMENT,
  `templateName` varchar(100) NOT NULL,
  `designName` varchar(100) NOT NULL,
  `designDescription` varchar(255) NOT NULL,
  `designContent` text NOT NULL,
  PRIMARY KEY (`designID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 UPDATE `settings` SET `data` = '2023081800' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DROP TABLE IF EXISTS `template_designs`;
 UPDATE `settings` SET `data` = '2023072000' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */