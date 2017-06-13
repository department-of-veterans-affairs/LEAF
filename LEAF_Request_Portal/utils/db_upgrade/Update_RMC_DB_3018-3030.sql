START TRANSACTION;


UPDATE `settings` SET `data` = '3030' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
