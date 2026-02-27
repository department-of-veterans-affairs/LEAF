START TRANSACTION;

ALTER TABLE `indicators` ADD COLUMN `dataElementID` MEDIUMINT(8) UNSIGNED DEFAULT NULL AFTER `trackChanges`;

UPDATE `settings` SET `data` = '2026022600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;



/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `indicators` DROP COLUMN `dataElementID`;

UPDATE `settings` SET `data` = '2025100200' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/