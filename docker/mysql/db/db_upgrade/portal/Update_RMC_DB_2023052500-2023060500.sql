START TRANSACTION;

CREATE TABLE `process_query` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`userID` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`url` TEXT NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	`lastProcess` INT(10) UNSIGNED NOT NULL,
	PRIMARY KEY (`id`) USING BTREE,
	FULLTEXT INDEX `url` (`url`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;


 UPDATE `settings` SET `data` = '2023060500' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DROP TABLE IF EXISTS `process_query`;
 UPDATE `settings` SET `data` = '2023052500' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */