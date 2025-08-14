START TRANSACTION;

INSERT INTO `dependencies` (`dependencyID`, `description`)
VALUES ('-4', 'LEAF Agent');

ALTER TABLE `indicators`
ADD `trackChanges` tinyint NOT NULL DEFAULT '1';


UPDATE `settings` SET `data` = '2025081400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;

DELETE FROM `dependencies`
WHERE ((`dependencyID` = '-4'));

ALTER TABLE `indicators`
DROP `trackChanges`;

UPDATE `settings` SET `data` = '2025041000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
