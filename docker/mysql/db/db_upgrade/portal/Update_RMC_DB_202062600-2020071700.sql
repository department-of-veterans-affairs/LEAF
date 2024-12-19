START TRANSACTION;

INSERT INTO `settings` (`setting`, `data`) VALUES ('sitemap_json', '{\"buttons\":[]}');

UPDATE `settings` SET `data` = '2020071700' WHERE `settings`.`setting` = 'dbversion';

COMMIT;