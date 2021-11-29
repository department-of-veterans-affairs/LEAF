START TRANSACTION;

ALTER TABLE `categories` ADD `type` VARCHAR(50) NOT NULL DEFAULT '' AFTER `disabled`;

UPDATE `settings` SET `data` = '5299' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
