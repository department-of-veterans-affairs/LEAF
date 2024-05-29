START TRANSACTION;

ALTER TABLE `data` ADD COLUMN `metadata` json DEFAULT NULL AFTER `data`;
ALTER TABLE `data_history` ADD COLUMN `metadata` json DEFAULT NULL AFTER `data`;

UPDATE `settings` SET `data` = '2024052000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;
ALTER TABLE `data` DROP COLUMN `metadata`;
ALTER TABLE `data_history` DROP COLUMN `metadata`;

UPDATE `settings` SET `data` = '2024022901' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
*/