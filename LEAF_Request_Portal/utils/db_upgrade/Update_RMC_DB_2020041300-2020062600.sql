START TRANSACTION;

ALTER TABLE `data_log_items` 
CHANGE COLUMN `value` `value` TEXT NOT NULL ;

SET SQL_SAFE_UPDATES=0;
UPDATE `data_action_log`
	SET
	`timestamp` = CONVERT_TZ( timestamp, @@session.time_zone, '+00:00' );
SET SQL_SAFE_UPDATES = 1;

UPDATE `settings` SET `data` = '202062600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;