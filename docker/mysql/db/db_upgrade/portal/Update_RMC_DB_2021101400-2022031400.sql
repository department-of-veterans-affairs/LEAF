START TRANSACTION;

ALTER TABLE `indicators` ADD COLUMN `condition` text NULL AFTER `htmlPrint`;

UPDATE `settings` SET `data` = '2022031400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `indicators` DROP COLUMN `condition`;

UPDATE `settings` SET `data` = '2021101400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
