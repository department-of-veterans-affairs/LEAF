START TRANSACTION;

ALTER TABLE `records` ADD `lastActionTime` int unsigned NULL AFTER `lastStatus`;

UPDATE `settings` SET `data` = '2024050900' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `records` DROP `lastActionTime`;

UPDATE `settings` SET `data` = '2024022901' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
*/
