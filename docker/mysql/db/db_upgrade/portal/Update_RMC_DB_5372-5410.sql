START TRANSACTION;

ALTER TABLE `settings` CHANGE `setting` `setting` VARCHAR(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `settings` CHANGE `data` `data` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;
INSERT INTO `settings` (`setting`, `data`) VALUES ('siteType', 'standard');
INSERT INTO `settings` (`setting`, `data`) VALUES ('national-linkedPrimary', ''), ('national-linkedSubordinateList', '');
UPDATE `settings` SET `setting` = 'subHeading' WHERE `settings`.`setting` = 'subheading';

UPDATE `settings` SET `data` = '5410' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
