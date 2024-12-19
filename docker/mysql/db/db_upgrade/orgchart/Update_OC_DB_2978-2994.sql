START TRANSACTION;

UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =2;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =3;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =4;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =5;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =6;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =8;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =9;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =11;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =12;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =13;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =14;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =17;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =18;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` =19;

UPDATE `settings` SET `data` = '2994' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
