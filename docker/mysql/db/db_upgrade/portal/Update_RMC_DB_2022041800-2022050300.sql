START TRANSACTION;

ALTER TABLE `indicators` ADD COLUMN `conditions` text NULL AFTER `htmlPrint`;

UPDATE `settings` SET `data` = '2022050300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `indicators` DROP COLUMN `conditions`;

UPDATE `settings` SET `data` = '2022041800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
