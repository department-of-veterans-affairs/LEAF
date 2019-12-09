START TRANSACTION;

ALTER TABLE `tags` MODIFY recordID int(11) unsigned NOT NULL;

UPDATE `settings` SET `data` = '2019120500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
