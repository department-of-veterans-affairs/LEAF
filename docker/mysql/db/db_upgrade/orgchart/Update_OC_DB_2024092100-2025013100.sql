START TRANSACTION;

ALTER TABLE `cache`
CHANGE `data` `data` text COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `cacheID`,
COLLATE 'utf8mb4_general_ci';

UPDATE `settings` SET `data` = '2025013100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `cache`
CHANGE `data` `data` text COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `cacheID`,
COLLATE 'utf8mb3_general_ci';

UPDATE `settings` SET `data` = '2024092100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/