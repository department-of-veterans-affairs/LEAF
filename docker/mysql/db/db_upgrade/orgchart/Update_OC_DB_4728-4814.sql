START TRANSACTION;

ALTER TABLE `employee`
DROP `AD_objectGUID`;

UPDATE `settings` SET `data` = '4814' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
