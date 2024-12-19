START TRANSACTION;

ALTER TABLE `categories` ALTER `visible` SET DEFAULT '-1';

UPDATE `settings` SET `data` = '2024100300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `categories` ALTER `visible` SET DEFAULT '1';

UPDATE `settings` SET `data` = '2024082000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/