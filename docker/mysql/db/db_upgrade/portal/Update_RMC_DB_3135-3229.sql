START TRANSACTION;


UPDATE `settings` SET `data` = '3229' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
