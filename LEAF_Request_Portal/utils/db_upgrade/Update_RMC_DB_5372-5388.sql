DELIMITER $$
CREATE PROCEDURE uuid_refactor_portal()
BEGIN
ALTER TABLE action_history MODIFY userID VARCHAR(255);
ALTER TABLE approvals MODIFY userID VARCHAR(255);
ALTER TABLE `data` MODIFY userID VARCHAR(255);
ALTER TABLE records MODIFY userID VARCHAR(255);
ALTER TABLE tags MODIFY userID VARCHAR(255);
ALTER TABLE users MODIFY userID VARCHAR(255);

DECLARE userID_old varchar(50) DEFAULT NULL;
DECLARE done TINYINT DEFAULT FALSE;

DEClARE uuid_cursor CURSOR FOR
SELECT userID FROM users;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN uuid_cursor;

uuid_loop: LOOP
  FETCH NEXT FROM uuid_cursor INTO userID_old;
  IF done THEN
    LEAVE uuid_loop;
  ELSE
    SET @uuid = UUID();
    UPDATE action_history SET userID = @uuid WHERE userID = userID_old;
    UPDATE approvals SET userID = @uuid WHERE userID = userID_old;
    UPDATE `data` SET userID = @uuid WHERE userID = userID_old;
    UPDATE records SET userID = @uuid WHERE userID = userID_old;
    UPDATE tags SET userID = @uuid WHERE userID = userID_old;
    UPDATE users SET userID = @uuid WHERE userID = userID_old;
  END IF;
END LOOP;
CLOSE uuid_cursor();
END$$
DELIMITER ;

CALL uuid_refactor_portal();

