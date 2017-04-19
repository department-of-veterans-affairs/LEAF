START TRANSACTION;

ALTER TABLE `employee` ADD `AD_objectGUID` VARCHAR(40) NOT NULL AFTER `phoneticLastName`;

UPDATE `settings` SET `data` = '3602' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
