START TRANSACTION;

ALTER TABLE `workflow_steps` CHANGE `iframeSrc` `jsSrc` VARCHAR(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;

UPDATE `settings` SET `data` = '3820' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
