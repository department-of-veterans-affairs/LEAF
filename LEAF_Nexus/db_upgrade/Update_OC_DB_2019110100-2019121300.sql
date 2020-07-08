START TRANSACTION;

ALTER TABLE employee ADD COLUMN new_empUUID VARCHAR(36) NULL;

/*
The following will have to be run on the national nexus manually, to avoid hitting all nexuses, should only take a minute
update employee set new_empUUID = uuid();
*/

UPDATE `settings` SET `data` = '2019121300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
