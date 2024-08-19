START TRANSACTION;

ALTER TABLE `records` ADD COLUMN `userMetadata` json DEFAULT NULL;
ALTER TABLE `notes` ADD COLUMN `userMetadata` json DEFAULT NULL;

UPDATE `settings` SET `data` = '2024082000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `records` DROP COLUMN `userMetadata`;
ALTER TABLE `notes` DROP COLUMN `userMetadata`;

UPDATE `settings` SET `data` = '2024071100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/