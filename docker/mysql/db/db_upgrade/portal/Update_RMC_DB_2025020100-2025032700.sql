START TRANSACTION;

ALTER TABLE `workflow_steps` ADD `stepType` tinyint NOT NULL DEFAULT '1' AFTER `stepTitle`;

UPDATE `settings` SET `data` = '2025032700' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;

ALTER TABLE `workflow_steps` DROP `stepType`;

UPDATE `settings` SET `data` = '2025020100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/