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
WL' WHERE `indicators`.`indicatorID` = 2;

UPDATE `settings` SET `data` = '2861' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
