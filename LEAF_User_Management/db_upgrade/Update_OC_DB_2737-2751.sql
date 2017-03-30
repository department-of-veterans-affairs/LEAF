START TRANSACTION;
UPDATE `groups` SET `groupTitle` = 'Owner', `phoneticGroupTitle` = 'ONR' WHERE `groups`.`groupID` =3;

UPDATE `settings` SET `data` = '2751' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
