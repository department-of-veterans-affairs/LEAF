START TRANSACTION;


UPDATE `settings` SET `data` = '3275' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
