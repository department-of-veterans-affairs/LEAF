START TRANSACTION;
ALTER TABLE `actions` ADD `fillDependency` TINYINT NOT NULL;
ALTER TABLE `workflow_routes` DROP `fillDependency`;
UPDATE `actions` SET `fillDependency` = '1' WHERE `actions`.`actionType` = 'approve';
UPDATE `actions` SET `fillDependency` = '1' WHERE `actions`.`actionType` = 'concur';
UPDATE `actions` SET `fillDependency` = '-2' WHERE `actions`.`actionType` = 'defer';
UPDATE `actions` SET `fillDependency` = '-1' WHERE `actions`.`actionType` = 'disapprove';

UPDATE `settings` SET `data` = '1551' WHERE `settings`.`setting` = 'dbversion';
COMMIT;