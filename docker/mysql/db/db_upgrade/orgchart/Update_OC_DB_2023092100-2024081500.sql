START TRANSACTION;

ALTER TABLE `employee` CHANGE COLUMN `userName` `userName` varchar(50) NOT NULL;

UPDATE `settings` SET `data` = '2024081500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `employee` CHANGE COLUMN `userName` `userName` varchar(30) NOT NULL;

UPDATE `settings` SET `data` = '2023092100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
