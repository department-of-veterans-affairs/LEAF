START TRANSACTION;

INSERT INTO `settings` (`setting`, `data`) VALUES ('heading', ''), ('subHeading', '');

UPDATE `settings` SET `data` = '4346' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
