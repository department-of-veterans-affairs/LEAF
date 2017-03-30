START TRANSACTION;

UPDATE indicators SET `format` = 'dropdown

GS
WG
VM
VN
NS
NA
AD
WS
WL
VP
VC' WHERE `indicators`.`indicatorID` = 2;

UPDATE `settings` SET `data` = '3749' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
