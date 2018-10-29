START TRANSACTION;

INSERT INTO settings (setting, data) VALUES ('salt', RAND());

UPDATE `settings` SET `data` = '5300' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
