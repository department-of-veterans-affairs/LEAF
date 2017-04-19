START TRANSACTION;

UPDATE `indicators` SET `format` = 'dropdown

GS
WG
VM
VN
NS
NA
AD
WS
WL
VP' WHERE `indicators`.`indicatorID` = 2;

UPDATE `settings` SET `data` = '3080' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
