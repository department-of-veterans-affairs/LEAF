START TRANSACTION;

ALTER TABLE `records` ADD PRIMARY KEY `PRIMARY` (`recordID`), DROP INDEX `PRIMARY`;

UPDATE `settings` SET `data` = '2024060700' WHERE `settings`.`setting` = 'dbversion';
COMMIT;



/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `records` ADD PRIMARY KEY `PRIMARY` (`recordID` DESC), DROP INDEX `PRIMARY`;

UPDATE `settings` SET `data` = '2024060600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/