START TRANSACTION;

ALTER TABLE `indicators` CHANGE `disabled` `disabled` INT UNSIGNED NOT NULL DEFAULT '0';

UPDATE `settings` SET `data` = '5008' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
