START TRANSACTION;

CREATE TABLE `process_query` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`userID` VARCHAR(50) NULL DEFAULT NULL,
	`url` TEXT NULL DEFAULT NULL,
	`lastProcess` INT(10) UNSIGNED NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `lastProcess` (`lastProcess`),
	FULLTEXT INDEX `url` (`url`),
	FULLTEXT INDEX `userid_url` (`userID`, `url`)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

 UPDATE `settings` SET `data` = '2023100500' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DROP TABLE IF EXISTS `process_query`;
 UPDATE `settings` SET `data` = '2023092100' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */
