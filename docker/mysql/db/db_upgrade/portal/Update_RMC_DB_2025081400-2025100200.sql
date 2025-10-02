START TRANSACTION;

DELETE FROM `dependency_privs` WHERE `dependencyID` = '-4';
UPDATE `dependencies` SET `description` = 'LEAF Agent' WHERE `dependencyID` = '-4';

UPDATE `settings` SET `data` = '2025100200' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;


UPDATE `settings` SET `data` = '2025041000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
