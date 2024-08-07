START TRANSACTION;

ALTER TABLE `employee_data` DROP FOREIGN KEY `empUID_rel`;
ALTER TABLE `employee_data` CHANGE `empUID` `empUID` int unsigned NOT NULL FIRST;
ALTER TABLE `relation_position_employee` DROP FOREIGN KEY `empUID_rel_position`;
ALTER TABLE `relation_position_employee` CHANGE `empUID` `empUID` int unsigned NOT NULL AFTER `positionID`;
ALTER TABLE `relation_group_employee` DROP FOREIGN KEY `empUID_rel_group`;
ALTER TABLE `relation_group_employee` CHANGE `empUID` `empUID` int unsigned NOT NULL AFTER `groupID`;
ALTER TABLE `relation_employee_backup` DROP FOREIGN KEY `empUID_rel_backup`;
ALTER TABLE `relation_employee_backup` DROP FOREIGN KEY `empUID_rel_backup2`;
ALTER TABLE `relation_employee_backup` CHANGE `empUID` `empUID` int unsigned NOT NULL FIRST,
    CHANGE `backupEmpUID` `backupEmpUID` int unsigned NOT NULL AFTER `empUID`;
ALTER TABLE `employee_privileges` DROP FOREIGN KEY `empUID_rel_privs`;
ALTER TABLE `employee_privileges` CHANGE `empUID` `empUID` int unsigned NOT NULL FIRST;
ALTER TABLE `employee_data_history` DROP FOREIGN KEY `empUID_rel_history`;
ALTER TABLE `employee_data_history` CHANGE `empUID` `empUID` int unsigned NOT NULL FIRST;
ALTER TABLE `employee` CHANGE `empUID` `empUID` int unsigned NOT NULL AUTO_INCREMENT FIRST;

ALTER TABLE `employee_data` ADD CONSTRAINT `empUID_rel` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_position_employee` ADD CONSTRAINT `empUID_rel_position` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_group_employee` ADD CONSTRAINT `empUID_rel_group` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_employee_backup` ADD CONSTRAINT `empUID_rel_backup` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_employee_backup` ADD CONSTRAINT `empUID_rel_backup2` FOREIGN KEY (`backupEmpUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `employee_privileges` ADD CONSTRAINT `empUID_rel_privs` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `employee_data_history` ADD CONSTRAINT `empUID_rel_history` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;

UPDATE `settings` SET `data` = '2024071800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;
ALTER TABLE `employee_data` DROP FOREIGN KEY `empUID_rel`;
ALTER TABLE `employee_data` CHANGE `empUID` `empUID` mediumint unsigned NOT NULL FIRST;
ALTER TABLE `relation_position_employee` DROP FOREIGN KEY `empUID_rel_position`;
ALTER TABLE `relation_position_employee` CHANGE `empUID` `empUID` mediumint unsigned NOT NULL AFTER `positionID`;
ALTER TABLE `relation_group_employee` DROP FOREIGN KEY `empUID_rel_group`;
ALTER TABLE `relation_group_employee` CHANGE `empUID` `empUID` mediumint unsigned NOT NULL AFTER `groupID`;
ALTER TABLE `relation_employee_backup` DROP FOREIGN KEY `empUID_rel_backup`;
ALTER TABLE `relation_employee_backup` DROP FOREIGN KEY `empUID_rel_backup2`;
ALTER TABLE `relation_employee_backup` CHANGE `empUID` `empUID` mediumint unsigned NOT NULL FIRST,
    CHANGE `backupEmpUID` `backupEmpUID` mediumint unsigned NOT NULL AFTER `empUID`;
ALTER TABLE `employee_privileges` DROP FOREIGN KEY `empUID_rel_privs`;
ALTER TABLE `employee_privileges` CHANGE `empUID` `empUID` mediumint unsigned NOT NULL FIRST;
ALTER TABLE `employee_data_history` DROP FOREIGN KEY `empUID_rel_history`;
ALTER TABLE `employee_data_history` CHANGE `empUID` `empUID` mediumint unsigned NOT NULL FIRST;
ALTER TABLE `employee` CHANGE `empUID` `empUID` mediumint unsigned NOT NULL AUTO_INCREMENT FIRST;

ALTER TABLE `employee_data` ADD CONSTRAINT `empUID_rel` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_position_employee` ADD CONSTRAINT `empUID_rel_position` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_group_employee` ADD CONSTRAINT `empUID_rel_group` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_employee_backup` ADD CONSTRAINT `empUID_rel_backup` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `relation_employee_backup` ADD CONSTRAINT `empUID_rel_backup2` FOREIGN KEY (`backupEmpUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `employee_privileges` ADD CONSTRAINT `empUID_rel_privs` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE `employee_data_history` ADD CONSTRAINT `empUID_rel_history` FOREIGN KEY (`empUID`) REFERENCES `employee`(`empUID`) ON DELETE CASCADE ON UPDATE RESTRICT;

UPDATE `settings` SET `data` = '2024071100' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
*/