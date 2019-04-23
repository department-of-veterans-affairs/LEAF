START TRANSACTION;



UPDATE `settings` SET `data` = '5432' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
