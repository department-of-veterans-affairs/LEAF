START TRANSACTION;

ALTER TABLE `sites` ALTER `isVAPO` SET DEFAULT 'true';

UPDATE `settings` SET `data` = '2024101500' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `sites` ALTER `isVAPO` SET DEFAULT 'false';

UPDATE `settings` SET `data` = '2024100300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
