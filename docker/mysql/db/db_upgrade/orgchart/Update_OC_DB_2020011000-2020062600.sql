START TRANSACTION;

ALTER TABLE `data_log_items` 
CHANGE COLUMN `value` `value` TEXT NOT NULL ;

SET SQL_SAFE_UPDATES=0;
UPDATE `data_action_log`
	SET
	`timestamp` = CONVERT_TZ( timestamp, @@session.time_zone, '+00:00' );
SET SQL_SAFE_UPDATES = 1;

INSERT INTO `settings` (`setting`, `data`) VALUES ('timeZone', 'America/New_York');

UPDATE `settings` SET `data` = '2020062600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;