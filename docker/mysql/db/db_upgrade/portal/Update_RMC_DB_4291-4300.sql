START TRANSACTION;

ALTER TABLE `categories` ADD `needToKnow` TINYINT NOT NULL DEFAULT '0' AFTER `sort`;

UPDATE `settings` SET `data` = '4300' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
