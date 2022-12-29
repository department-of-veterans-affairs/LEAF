START TRANSACTION;

INSERT INTO `settings` (`setting`, `data`) VALUES ('heading', ''), ('subheading', '');

UPDATE `settings` SET `data` = '4346' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
