START TRANSACTION;

UPDATE `indicators` SET `sort` = '1' WHERE `indicators`.`indicatorID` =7;
UPDATE `indicators` SET `name` = 'Position in Org. Chart' WHERE `indicators`.`indicatorID` =7;

UPDATE `settings` SET `data` = '3032' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
