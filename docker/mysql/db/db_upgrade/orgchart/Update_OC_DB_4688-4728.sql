START TRANSACTION;

ALTER TABLE `employee` CHANGE `AD_objectGUID` `AD_objectGUID` VARCHAR(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL;

UPDATE `settings` SET `data` = '4728' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
