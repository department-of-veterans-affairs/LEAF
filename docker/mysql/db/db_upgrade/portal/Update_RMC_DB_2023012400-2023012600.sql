START TRANSACTION;

ALTER TABLE `records_workflow_state` ADD COLUMN `initialNotificationSent` TINYINT(1) NULL DEFAULT '0' AFTER `lastNotified`;

CREATE INDEX idx_lastNotified ON records_workflow_state (lastNotified);

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `records_workflow_state` DROP COLUMN `initialNotificationSent`;

DROP INDEX idx_lastNotified ON records_workflow_state;

COMMIT;

*/