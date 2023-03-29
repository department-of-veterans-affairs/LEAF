START TRANSACTION;

ALTER TABLE `categories` ADD COLUMN `destructionAge` TINYINT UNSIGNED NULL DEFAULT NULL AFTER `type`;

UPDATE `settings` SET `data` = '2023030900' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****

START TRANSACTION;

ALTER TABLE `categories` DROP COLUMN `destructionAge`;

UPDATE `settings` SET `data` = '2023012600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
