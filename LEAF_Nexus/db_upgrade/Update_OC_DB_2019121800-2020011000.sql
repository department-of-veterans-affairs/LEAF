START TRANSACTION;

ALTER TABLE `data_action_log` 
ADD COLUMN `userDisplay` VARCHAR(255) NULL ;

SET SQL_SAFE_UPDATES=0;
UPDATE data_action_log dal,
	employee e
Set
	dal.userDisplay = concat(e.firstName, " " , e.lastName)
where dal.userID = e.empUID;
SET SQL_SAFE_UPDATES=1;

UPDATE `settings` SET `data` = '2020011000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;