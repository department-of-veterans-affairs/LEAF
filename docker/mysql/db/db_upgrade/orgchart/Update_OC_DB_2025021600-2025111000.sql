START TRANSACTION;

ALTER TABLE employee MODIFY COLUMN empUID INT unsigned AUTO_INCREMENT;
ALTER TABLE relation_position_employee MODIFY COLUMN empUID INT unsigned;
ALTER TABLE relation_group_employee MODIFY COLUMN empUID INT unsigned;
ALTER TABLE relation_employee_backup MODIFY COLUMN empUID INT unsigned;
ALTER TABLE employee_privileges MODIFY COLUMN empUID INT unsigned;
ALTER TABLE employee_data_history MODIFY COLUMN empUID INT unsigned;
ALTER TABLE employee_data MODIFY COLUMN empUID INT unsigned;

UPDATE `settings` SET `data` = '2025111000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE employee MODIFY COLUMN empUID mediumint unsigned AUTO_INCREMENT;
ALTER TABLE relation_position_employee MODIFY COLUMN empUID mediumint unsigned;
ALTER TABLE relation_group_employee MODIFY COLUMN empUID mediumint unsigned;
ALTER TABLE relation_employee_backup MODIFY COLUMN empUID mediumint unsigned;
ALTER TABLE employee_privileges MODIFY COLUMN empUID mediumint unsigned;
ALTER TABLE employee_data_history MODIFY COLUMN empUID mediumint unsigned;
ALTER TABLE employee_data MODIFY COLUMN empUID mediumint unsigned;

UPDATE `settings` SET `data` = '2025021600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/