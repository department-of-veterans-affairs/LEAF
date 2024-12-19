START TRANSACTION;

ALTER TABLE `relation_position_employee` ADD `isActing` TINYINT NOT NULL DEFAULT '0' AFTER `empUID`;

UPDATE `settings` SET `data` = '4403' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
