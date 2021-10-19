START TRANSACTION;

ALTER TABLE `actions` ADD `deleted` TINYINT(1)  NULL  DEFAULT '0'  AFTER `fillDependency`;

UPDATE `settings` SET `data` = '5372' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
