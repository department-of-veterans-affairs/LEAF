START TRANSACTION;

INSERT INTO `settings` (`setting`, `data`) VALUES
('adPath', ''),
('emailBCC', '{}'),
('emailCC', '{}'),
('emailPrefix', 'Resources: ');

UPDATE `settings` SET `data` = '2022110300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
