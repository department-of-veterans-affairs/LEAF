START TRANSACTION;

ALTER TABLE `data` DROP FOREIGN KEY `data_ibfk_2` ;
ALTER TABLE `indicator_mask` DROP FOREIGN KEY `indicator_mask_ibfk_1` ;

UPDATE `settings` SET `data` = '3018' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
