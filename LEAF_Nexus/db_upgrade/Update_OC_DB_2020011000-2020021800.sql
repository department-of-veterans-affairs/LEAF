START TRANSACTION;

UPDATE 
  employee emp,
  national_orgchart.employee nat_emp
SET 
  emp.new_empUUID = nat_emp.new_empUUID
WHERE 
  emp.userName= nat_emp.userName;
  
UPDATE 
  employee
SET 
  new_empUUID = CONCAT('not_in_national_', empUID)
WHERE 
  new_empUUID IS NULL;

UPDATE `settings` SET `data` = '2020021800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;