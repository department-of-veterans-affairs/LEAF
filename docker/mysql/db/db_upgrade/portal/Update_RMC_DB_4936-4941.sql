START TRANSACTION;

ALTER TABLE `service_chiefs` ADD `active` TINYINT NOT NULL DEFAULT '1' AFTER `locallyManaged`;
ALTER TABLE `service_chiefs` CHANGE `locallyManaged` `locallyManaged` TINYINT(1) NULL DEFAULT '0';
UPDATE `service_chiefs` SET locallyManaged=0 WHERE locallyManaged IS NULL;

UPDATE `settings` SET `data` = '4941' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
