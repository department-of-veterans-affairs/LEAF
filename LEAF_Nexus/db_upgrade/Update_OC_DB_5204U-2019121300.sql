START TRANSACTION;
ALTER TABLE employee ADD COLUMN new_empUUID VARCHAR(36) NULL;

update employee set new_empUUID = uuid();

UPDATE `settings` SET `data` = '2019121300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;