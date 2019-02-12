DELIMITER $$
CREATE PROCEDURE uuid_refactor_orgchart()
BEGIN
ALTER TABLE employee MODIFY empUID VARCHAR(255);
ALTER TABLE employee MODIFY userName VARCHAR(255);
ALTER TABLE employee_data MODIFY empUID VARCHAR(255);
ALTER TABLE employee_data MODIFY author VARCHAR(255);
ALTER TABLE employee_data_history MODIFY empUID VARCHAR(255);
ALTER TABLE employee_data_history MODIFY author VARCHAR(255);
ALTER TABLE position_data MODIFY author VARCHAR(255);
ALTER TABLE position_data_history MODIFY author VARCHAR(255);
ALTER TABLE relation_employee_backup MODIFY empUID VARCHAR(255);
ALTER TABLE relation_employee_backup MODIFY approverUserName VARCHAR(255);

DECLARE empUID_old mediumint(8) DEFAULT NULL;
DECLARE userName_old varchar(30) DEFAULT NULL;
DECLARE done TINYINT DEFAULT FALSE;

DEClARE uuid_cursor CURSOR FOR
SELECT empUID, userName FROM employee;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN uuid_cursor;

uuid_loop: LOOP
  FETCH NEXT FROM uuid_cursor INTO empUID_old, userName_old;
  IF done THEN
    LEAVE uuid_loop;
  ELSE
    SET @uuid = UUID();
    UPDATE employee SET empUID = @uuid, userName = @uuid WHERE empUID = empUID_old;
    UPDATE employee_data SET empUID = @uuid, author = @uuid WHERE empUID = empUID_old;
    UPDATE employee_data_history SET empUID = @uuid, author = @uuid WHERE empUID = empUID_old;
    UPDATE position_data SET author = @uuid WHERE author = userName_old;
    UPDATE position_data_history SET author = @uuid WHERE author = userName_old;
    UPDATE relation_employee_backup SET empUID = @uuid, approverUserName = @uuid WHERE empUID = empUID_old;
  END IF;
END LOOP;
CLOSE uuid_cursor();
END$$
DELIMITER ;

CALL uuid_refactor_orgchart();

