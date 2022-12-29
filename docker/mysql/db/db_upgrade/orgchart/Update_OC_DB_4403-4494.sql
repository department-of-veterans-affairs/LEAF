START TRANSACTION;

INSERT INTO `settings` (`setting`, `data`) VALUES ('heading', '');
INSERT INTO `settings` (`setting`, `data`) VALUES ('subheading', '');

UPDATE `settings` SET `data` = '4494' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
