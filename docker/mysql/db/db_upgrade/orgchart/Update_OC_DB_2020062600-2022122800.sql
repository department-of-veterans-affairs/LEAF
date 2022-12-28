START TRANSACTION;

UPDATE `settings` SET `setting` = 'subHeading' WHERE `settings`.`setting` = 'subheading';

UPDATE `settings` SET `data` = '2022122800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
