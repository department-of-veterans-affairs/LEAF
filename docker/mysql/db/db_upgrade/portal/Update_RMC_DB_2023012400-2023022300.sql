START TRANSACTION;

ALTER TABLE notes MODIFY recordID mediumint(8) UNSIGNED NOT NULL;

UPDATE `settings` SET `data` = '2023022300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE notes MODIFY recordID mediumint(5) UNSIGNED NOT NULL;

UPDATE `settings` SET `data` = '2023012400' WHERE `settings`.`setting` = 'dbversion';


COMMIT;

*/
