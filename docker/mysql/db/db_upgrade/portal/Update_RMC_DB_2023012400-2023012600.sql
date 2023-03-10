START TRANSACTION;

ALTER TABLE `records_workflow_state` ADD COLUMN `initialNotificationSent` TINYINT(1) NULL DEFAULT '0' AFTER `lastNotified`;

CREATE INDEX idx_lastNotified ON records_workflow_state (lastNotified);

UPDATE `settings` SET `data` = '2023012600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `records_workflow_state` DROP COLUMN `initialNotificationSent`;

DROP INDEX idx_lastNotified ON records_workflow_state;

UPDATE `settings` SET `data` = '2023012400' WHERE `settings`.`setting` = 'dbversion';


COMMIT;

*/