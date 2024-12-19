START TRANSACTION;

ALTER TABLE `data`
CHANGE `data` `data` text COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `series`,
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `timestamp`,
COLLATE 'utf8mb4_general_ci';

ALTER TABLE `data_history`
CHANGE `data` `data` text COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `series`,
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `timestamp`,
CHANGE `userDisplay` `userDisplay` varchar(90) COLLATE 'utf8mb4_general_ci' NULL AFTER `userID`,
COLLATE 'utf8mb4_general_ci';

ALTER TABLE `records`
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `serviceID`,
CHANGE `title` `title` text COLLATE 'utf8mb4_general_ci' NULL AFTER `userID`,
CHANGE `lastStatus` `lastStatus` text COLLATE 'utf8mb4_general_ci' NULL AFTER `priority`,
COLLATE 'utf8mb4_general_ci';


UPDATE `settings` SET `data` = '2024112500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ***** NOTE: Data could have issues going back if it contains data that is in the mb4 set
START TRANSACTION;

ALTER TABLE `data`
CHANGE `data` `data` text COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `series`,
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `timestamp`,
COLLATE 'utf8mb3_general_ci';

ALTER TABLE `data_history`
CHANGE `data` `data` text COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `series`,
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `timestamp`,
CHANGE `userDisplay` `userDisplay` varchar(90) COLLATE 'utf8mb3_general_ci' NULL AFTER `userID`,
COLLATE 'utf8mb3_general_ci';

ALTER TABLE `records`
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `serviceID`,
CHANGE `title` `title` text COLLATE 'utf8mb3_general_ci' NULL AFTER `userID`,
COLLATE 'utf8mb3_general_ci';

UPDATE `settings` SET `data` = '2024101500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
