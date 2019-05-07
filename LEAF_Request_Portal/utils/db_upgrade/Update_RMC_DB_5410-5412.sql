START TRANSACTION;

UPDATE `settings` SET `setting` = 'national_linkedPrimary' WHERE `settings`.`setting` = 'national-linkedPrimary';
UPDATE `settings` SET `setting` = 'national_linkedSubordinateList' WHERE `settings`.`setting` = 'national-linkedSubordinateList';

UPDATE `settings` SET `data` = '5412' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
