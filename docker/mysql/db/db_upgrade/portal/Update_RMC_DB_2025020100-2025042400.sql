START TRANSACTION;

INSERT INTO `dependencies` (`dependencyID`, `description`)
VALUES ('-4', 'LEAF Agent');

UPDATE `settings` SET `data` = '2025042400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;

DELETE FROM `dependencies`
WHERE ((`dependencyID` = '-4'));

UPDATE `settings` SET `data` = '2025020100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/