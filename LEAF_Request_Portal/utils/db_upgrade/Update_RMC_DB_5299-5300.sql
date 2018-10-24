START TRANSACTION;

INSERT INTO settings (setting, data) VALUES ('salt', FLOOR(RAND() * 10000));

UPDATE `settings` SET `data` = '5300' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
