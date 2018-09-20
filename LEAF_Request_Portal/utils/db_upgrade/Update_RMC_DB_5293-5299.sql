START TRANSACTION;

ALTER TABLE `categories` ADD `parallelProcessing` TINYINT NOT NULL DEFAULT '0' AFTER `disabled`;

UPDATE `settings` SET `data` = '5299' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
