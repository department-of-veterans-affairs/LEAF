START TRANSACTION;
ALTER TABLE `users` ADD `primary_admin` bool NOT NULL default 0;
  
  
UPDATE `settings` SET `data` = '2020012400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;