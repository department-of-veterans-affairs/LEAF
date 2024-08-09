START TRANSACTION;

ALTER TABLE `employee` CHANGE COLUMN `userName` `userName` varchar(50) NOT NULL;

UPDATE `settings` SET `data` = '2024081500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `relation_employee_backup` DROP INDEX `backupEmpUID`;

UPDATE `settings` SET `data` = '2020062600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
