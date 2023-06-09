START TRANSACTION;

CREATE TABLE `process_query` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `userID` VARCHAR(50) DEFAULT NULL,
  `url` TEXT DEFAULT NULL,
  `lastProcess` INT(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 UPDATE `settings` SET `data` = '2023060500' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DROP TABLE IF EXISTS `process_query`;
 UPDATE `settings` SET `data` = '2023052500' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */