START TRANSACTION;

ALTER TABLE notes MODIFY recordID mediumint(8) UNSIGNED NOT NULL;
ALTER TABLE signatures MODIFY recordID mediumint(8) UNSIGNED NOT NULL;
ALTER TABLE signatures MODIFY stepID smallint(6);
ALTER TABLE signatures MODIFY dependencyID smallint(6);
ALTER TABLE tags MODIFY recordID mediumint(8) UNSIGNED NOT NULL;
ALTER TABLE `groups` MODIFY parentGroupID mediumint(9);

UPDATE `settings` SET `data` = '2023022300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE notes MODIFY recordID mediumint(5) UNSIGNED NOT NULL;
ALTER TABLE signatures MODIFY recordID smallint(5) UNSIGNED NOT NULL;
ALTER TABLE signatures MODIFY stepID smallint(5);
ALTER TABLE signatures MODIFY dependencyID smallint(5);
ALTER TABLE tags MODIFY recordID int(11) UNSIGNED NOT NULL;
ALTER TABLE `groups` MODIFY parentGroupID tinyint(4);

UPDATE `settings` SET `data` = '2023012600' WHERE `settings`.`setting` = 'dbversion';


COMMIT;

*/
