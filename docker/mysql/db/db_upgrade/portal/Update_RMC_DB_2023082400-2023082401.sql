START TRANSACTION;

ALTER TABLE `services` DROP INDEX `service`;

UPDATE `settings` SET `data` = '2023082401' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `services` ADD UNIQUE `service` (`service`);

UPDATE `settings` SET `data` = '2023082400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
