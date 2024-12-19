START TRANSACTION;

UPDATE `events` SET `eventDescription` = 'Notify the next approver via email' WHERE `events`.`eventID` = 'std_email_notify_next_approver';
UPDATE `events` SET `eventDescription` = 'Notify the requestor via email' WHERE `events`.`eventID` = 'std_email_notify_completed';

UPDATE `settings` SET `data` = '4344' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
