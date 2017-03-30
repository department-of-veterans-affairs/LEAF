START TRANSACTION;

INSERT INTO `settings` (`setting`, `data`)
VALUES ('timeZone', 'America/New_York');

UPDATE `settings` SET `data` = '4691' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
