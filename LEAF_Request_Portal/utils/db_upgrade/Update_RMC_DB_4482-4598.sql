START TRANSACTION;

INSERT INTO `settings` (`setting`, `data`) VALUES ('requestLabel', 'Request');

UPDATE `settings` SET `data` = '4598' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
