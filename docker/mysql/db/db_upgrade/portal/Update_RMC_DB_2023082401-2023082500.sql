START TRANSACTION;

CREATE TABLE `template_designs` (
  `designID` int(11) NOT NULL AUTO_INCREMENT,
  `templateName` varchar(50) NOT NULL,
  `designName` varchar(50) NOT NULL,
  `designContent` text NOT NULL,
  PRIMARY KEY (`designID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 UPDATE `settings` SET `data` = '2023082500' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;

 /*revert also ensures that no homepages are enabled*/
 /**** Revert DB *****
 START TRANSACTION;
 UPDATE `settings` SET `data` = '0' WHERE `settings`.`setting` = 'homepage_enabled';

 DROP TABLE IF EXISTS `template_designs`;
 UPDATE `settings` SET `data` = '2023082401' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;
 */