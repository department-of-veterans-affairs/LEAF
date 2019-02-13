START TRANSACTION;

ALTER TABLE `employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL DEFAULT '0' FIRST;
ALTER TABLE `employee_data` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `employee_data_history` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `employee_privileges` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `relation_employee_backup` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `relation_employee_backup` CHANGE `backupEmpUID` `backupEmpUID` varchar(36) NOT NULL;
ALTER TABLE `relation_group_employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `relation_position_employee` CHANGE `empUID` `empUID` varchar(36) NOT NULL;

ALTER TABLE `employee_data` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `employee_data_history` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `group_data` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `group_data_history` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `position_data` CHANGE `author` `author` varchar(36) NOT NULL;
ALTER TABLE `position_data_history` CHANGE `author` `author` varchar(36) NOT NULL;

ALTER TABLE `relation_employee_backup` CHANGE `approverUserName` `approverUserName` varchar(36);

DELIMITER #
CREATE TRIGGER `employee_new_empUID`
BEFORE INSERT ON `employee` 
FOR EACH ROW 
BEGIN 
    IF NEW.empUID = '0' THEN 
        SET NEW.empUID = UUID(); 
    END IF;
END;
#
DELIMITER ;

UPDATE `settings` SET `data` = '5205' WHERE `settings`.`setting` = 'dbversion';

COMMIT;