START TRANSACTION;

ALTER TABLE `categories` ADD `lastModified` INT UNSIGNED NOT NULL DEFAULT '0' AFTER `type`;

UPDATE `settings` SET `data` = '2019082300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
