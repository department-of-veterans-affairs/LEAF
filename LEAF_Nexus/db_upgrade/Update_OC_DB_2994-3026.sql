START TRANSACTION;

UPDATE `indicators` SET `name` = 'Total Headcount' WHERE `indicators`.`indicatorID` =19;

UPDATE `settings` SET `data` = '3026' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
