START TRANSACTION;

ALTER TABLE `employee_data`
DROP FOREIGN KEY IF EXISTS `empUID_rel`;
ALTER TABLE `employee_data_history`
DROP FOREIGN KEY IF EXISTS `empUID_rel_history`;
ALTER TABLE `employee_privileges`
DROP FOREIGN KEY IF EXISTS `empUID_rel_privs`;
ALTER TABLE `relation_employee_backup`
DROP FOREIGN KEY IF EXISTS `empUID_rel_backup`;
ALTER TABLE `relation_employee_backup`
DROP FOREIGN KEY IF EXISTS `empUID_rel_backup2`;
ALTER TABLE `relation_group_employee`
DROP FOREIGN KEY IF EXISTS `empUID_rel_group`;
ALTER TABLE `relation_position_employee`
DROP FOREIGN KEY IF EXISTS `empUID_rel_position`;

ALTER TABLE `employee_data`
ADD INDEX `author` (`author`);
ALTER TABLE `employee_data_history`
ADD INDEX `author` (`author`);
ALTER TABLE `employee_privileges`
ADD INDEX `UID` (`UID`);
ALTER TABLE `relation_employee_backup`
ADD INDEX `backupEmpUID` (`backupEmpUID`);
ALTER TABLE `relation_employee_backup`
ADD INDEX `approverUserName` (`approverUserName`);
ALTER TABLE `group_data`
ADD INDEX `author` (`author`);
ALTER TABLE `group_data_history`
ADD INDEX `author` (`author`);
ALTER TABLE `position_data`
ADD INDEX `author` (`author`);
ALTER TABLE `position_data_history`
ADD INDEX `author` (`author`);
ALTER TABLE `group_privileges`
ADD INDEX `UID` (`UID`);
ALTER TABLE `indicator_privileges`
ADD INDEX `UID` (`UID`);
ALTER TABLE `position_privileges`
ADD INDEX `UID` (`UID`);

ALTER TABLE `employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL DEFAULT '0' FIRST;
ALTER TABLE `employee_data` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `employee_data_history` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `employee_privileges` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `relation_employee_backup` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `relation_employee_backup` CHANGE `backupEmpUID` `backupEmpUID` varchar(36) NOT NULL;
ALTER TABLE `relation_group_employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `relation_position_employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL;

ALTER TABLE `employee_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;
ALTER TABLE `group_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;
ALTER TABLE `indicator_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;
ALTER TABLE `position_privileges` CHANGE `UID` `UID` varchar(36) NOT NULL;

ALTER TABLE `employee_data` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `employee_data_history` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `group_data` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `group_data_history` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `position_data` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `position_data_history` CHANGE `author` `author` varchar(36) NOT NULL;

ALTER TABLE `relation_employee_backup` CHANGE `approverUserName` `approverUserName` varchar(36);

UPDATE `settings` SET `data` = '2019082300' WHERE `settings`.`setting` = 'dbversion';
COMMIT;