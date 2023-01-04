START TRANSACTION;

SET SQL_SAFE_UPDATES=0;

INSERT INTO `settings` (`setting`, `data`) VALUES
('adPath', ''),
('ERM_Sites', '{"resource_management":""}');

UPDATE `settings` SET `setting` = 'subHeading' WHERE `settings`.`setting` = 'subheading';

UPDATE `settings` SET `data` = '2022122900' WHERE `settings`.`setting` = 'dbversion';

COMMIT;