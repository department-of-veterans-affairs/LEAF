START TRANSACTION;

ALTER TABLE `records` DROP FOREIGN KEY `records_ibfk_1` ;
ALTER TABLE `services` DROP FOREIGN KEY `services_ibfk_1` ;
ALTER TABLE `service_chiefs` DROP FOREIGN KEY `service_chiefs_ibfk_1` ;
ALTER TABLE `service_data` DROP FOREIGN KEY `service_data_ibfk_1` ;
ALTER TABLE `service_data` DROP FOREIGN KEY `service_data_ibfk_2` ;

UPDATE `settings` SET `data` = '3008' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
