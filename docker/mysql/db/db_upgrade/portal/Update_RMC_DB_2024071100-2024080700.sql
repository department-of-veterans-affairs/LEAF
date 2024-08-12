START TRANSACTION;

-- this table is not used, was for the previous iteration of this process, easier to just remove and restart
DROP TABLE IF EXISTS `process_query`;

CREATE TABLE `process_query` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`userID` VARCHAR(50) NULL DEFAULT NULL,
	`sql` TEXT NULL DEFAULT NULL,
    `data` TEXT NULL DEFAULT NULL,
	`lastProcess` INT(10) UNSIGNED NOT NULL,
	PRIMARY KEY (`id`),
	INDEX `lastProcess` (`lastProcess`),

FULLTEXT INDEX `userid_url` (`userID`,`sql`,`data`)

)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE `settings` SET `data` = '2024080700' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

DROP TABLE IF EXISTS `process_query`;

UPDATE `settings` SET `data` = '2024071100' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
*/