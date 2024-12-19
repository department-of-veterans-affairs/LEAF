START TRANSACTION;
ALTER TABLE `workflow_steps` ADD `iframeSrc` VARCHAR( 128 ) NOT NULL;


UPDATE `settings` SET `data` = '1550' WHERE `settings`.`setting` = 'dbversion';
COMMIT;