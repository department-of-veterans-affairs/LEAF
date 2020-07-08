START TRANSACTION;

DELETE FROM `route_events` WHERE `route_events`.`workflowID` = -2 AND `route_events`.`stepID` = -4 AND `route_events`.`actionType` = 'approve' AND `route_events`.`eventID` = 'std_email_notify_next_approver';
INSERT INTO `route_events` (`workflowID`, `stepID`, `actionType`, `eventID`) VALUES ('-2', '-4', 'approve', 'LeafSecure_DeveloperConsole'); 
INSERT INTO `route_events` (`workflowID`, `stepID`, `actionType`, `eventID`) VALUES ('-2', '-4', 'approve', 'std_email_notify_completed'); 

UPDATE `settings` SET `data` = '2020021900' WHERE `settings`.`setting` = 'dbversion';

COMMIT;