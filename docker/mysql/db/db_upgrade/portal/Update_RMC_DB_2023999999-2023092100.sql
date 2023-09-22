START TRANSACTION;

ALTER TABLE `relation_employee_backup` ADD INDEX `backupEmpUID` (`backupEmpUID`);

UPDATE `settings` SET `data` = '2023092100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `relation_employee_backup` DROP INDEX `backupEmpUID`;

UPDATE `settings` SET `data` = '2023999999' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
