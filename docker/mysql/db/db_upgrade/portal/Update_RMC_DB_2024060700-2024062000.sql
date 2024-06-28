START TRANSACTION;

ALTER TABLE `action_history` ADD COLUMN `userMetadata` json DEFAULT NULL;

UPDATE `settings` SET `data` = '2024062000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;
ALTER TABLE `action_history` DROP COLUMN `userMetadata`;

UPDATE `settings` SET `data` = '2024060700' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
*/