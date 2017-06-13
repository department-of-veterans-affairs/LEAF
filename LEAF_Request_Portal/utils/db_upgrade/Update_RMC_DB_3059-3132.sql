START TRANSACTION;

ALTER TABLE `actions` CHANGE `actionType` `actionType` VARCHAR( 50 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL ;
ALTER TABLE `actions` CHANGE `actionText` `actionText` VARCHAR( 50 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL ;
ALTER TABLE `actions` CHANGE `actionTextPasttense` `actionTextPasttense` VARCHAR( 50 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL;


UPDATE `settings` SET `data` = '3132' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
