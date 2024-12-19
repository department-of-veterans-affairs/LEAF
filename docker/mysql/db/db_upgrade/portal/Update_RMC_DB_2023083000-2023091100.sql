START TRANSACTION;

ALTER TABLE `data` ADD FULLTEXT `data` (`data`);

UPDATE `settings` SET `data` = '2023091100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `data` DROP INDEX `data`;

UPDATE `settings` SET `data` = '2023083000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
