START TRANSACTION;

ALTER TABLE `workflow_steps` ADD `posX` SMALLINT NULL DEFAULT NULL , ADD `posY` SMALLINT NULL DEFAULT NULL ;

UPDATE `settings` SET `data` = '3846' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
