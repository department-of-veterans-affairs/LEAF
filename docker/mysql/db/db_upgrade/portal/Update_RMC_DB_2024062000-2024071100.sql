START TRANSACTION;

ALTER TABLE `sites` ADD COLUMN `isVAPO` varchar(8) NOT NULL DEFAULT 'false' AFTER `decommissionTimestamp`;
ALTER TABLE `sites` ADD INDEX `isVAPO` (`isVAPO`);
ALTER TABLE `sites` ADD INDEX `site_type` (`site_type`);

UPDATE `settings` SET `data` = '2024071100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;
ALTER TABLE `sites` DROP COLUMN `isVAPO`;

UPDATE `settings` SET `data` = '2024062000' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
*/