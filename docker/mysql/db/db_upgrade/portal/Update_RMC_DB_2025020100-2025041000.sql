START TRANSACTION;

ALTER TABLE `action_history`
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `recordID`,
CHANGE `actionType` `actionType` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `dependencyID`,
CHANGE `comment` `comment` text COLLATE 'utf8mb4_general_ci' NULL AFTER `time`,
COLLATE 'utf8mb4_general_ci';


ALTER TABLE `action_types`
CHANGE `actionTypeDesc` `actionTypeDesc` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `actionTypeID`,
COLLATE 'utf8mb4_general_ci';

ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_actionType`;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_1`;

ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_event`;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_2`;

ALTER TABLE `workflow_routes` DROP FOREIGN KEY `workflow_routes_actionType`;
ALTER TABLE `workflow_routes` DROP FOREIGN KEY `workflow_routes_ibfk_3`;

ALTER TABLE `actions`
CHANGE `actionType` `actionType` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL,
CHANGE `actionText` `actionText` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `actionType`,
CHANGE `actionTextPasttense` `actionTextPasttense` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `actionText`,
CHANGE `actionIcon` `actionIcon` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `actionTextPasttense`,
CHANGE `actionAlignment` `actionAlignment` varchar(20) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `actionIcon`,
COLLATE 'utf8mb4_general_ci';

ALTER TABLE `route_events`
CHANGE `actionType` `actionType` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `stepID`,
CHANGE `eventID` `eventID` varchar(40) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `actionType`,
COLLATE 'utf8mb4_general_ci';

ALTER TABLE `events`
CHANGE `eventID` `eventID` varchar(40) COLLATE 'utf8mb4_general_ci' NOT NULL,
CHANGE `eventDescription` `eventDescription` varchar(200) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `eventID`,
CHANGE `eventType` `eventType` varchar(40) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `eventDescription`,
CHANGE `eventData` `eventData` text COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `eventType`,
COLLATE 'utf8mb4_general_ci';

ALTER TABLE `workflow_routes`
CHANGE `actionType` `actionType` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `nextStepID`,
CHANGE `displayConditional` `displayConditional` text COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `actionType`,
COLLATE 'utf8mb4_general_ci';

ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_1` FOREIGN KEY (`actionType`) REFERENCES `actions`(`actionType`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `workflow_routes` ADD CONSTRAINT `workflow_routes_ibfk_3` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`) ON DELETE RESTRICT ON UPDATE RESTRICT;


ALTER TABLE `approvals`
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `recordID`,
CHANGE `approvalType` `approvalType` varchar(50) COLLATE 'utf8mb4_general_ci' NOT NULL AFTER `groupID`,
CHANGE `comment` `comment` text COLLATE 'utf8mb4_general_ci' NULL AFTER `time`,
COLLATE 'utf8mb4_general_ci';


UPDATE `settings` SET `data` = '2025041000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;



/**** Revert DB ***** NOTE: Data could have issues going back if it contains data that is in the mb4 set

START TRANSACTION;

ALTER TABLE `action_history`
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `recordID`,
CHANGE `actionType` `actionType` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `dependencyID`,
CHANGE `comment` `comment` text COLLATE 'utf8mb3_general_ci' NULL AFTER `time`,
COLLATE 'utf8mb3_general_ci';


ALTER TABLE `action_types`
CHANGE `actionTypeDesc` `actionTypeDesc` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `actionTypeID`,
COLLATE 'utf8mb3_general_ci';



ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_1`;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_2`;
ALTER TABLE `workflow_routes` DROP FOREIGN KEY `workflow_routes_ibfk_3`;

ALTER TABLE `actions`
CHANGE `actionType` `actionType` varchar(50) COLLATE 'latin1_swedish_ci' NOT NULL,
CHANGE `actionText` `actionText` varchar(50) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `actionType`,
CHANGE `actionTextPasttense` `actionTextPasttense` varchar(50) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `actionText`,
CHANGE `actionIcon` `actionIcon` varchar(50) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `actionTextPasttense`,
CHANGE `actionAlignment` `actionAlignment` varchar(20) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `actionIcon`,
COLLATE 'latin1_swedish_ci';

ALTER TABLE `route_events`
CHANGE `actionType` `actionType` varchar(50) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `stepID`,
CHANGE `eventID` `eventID` varchar(40) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `actionType`,
COLLATE 'latin1_swedish_ci';

ALTER TABLE `events`
CHANGE `eventID` `eventID` varchar(40) COLLATE 'latin1_swedish_ci' NOT NULL,
CHANGE `eventDescription` `eventDescription` varchar(200) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `eventID`,
CHANGE `eventType` `eventType` varchar(40) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `eventDescription`,
CHANGE `eventData` `eventData` text COLLATE 'latin1_swedish_ci' NOT NULL AFTER `eventType`,
COLLATE 'latin1_swedish_ci';

ALTER TABLE `workflow_routes`
CHANGE `actionType` `actionType` varchar(50) COLLATE 'latin1_swedish_ci' NOT NULL AFTER `nextStepID`,
CHANGE `displayConditional` `displayConditional` text COLLATE 'latin1_swedish_ci' NOT NULL AFTER `actionType`,
COLLATE 'latin1_swedish_ci';

ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_1` FOREIGN KEY (`actionType`) REFERENCES `actions`(`actionType`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `workflow_routes` ADD CONSTRAINT `workflow_routes_ibfk_3` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`) ON DELETE RESTRICT ON UPDATE RESTRICT;



ALTER TABLE `approvals`
CHANGE `userID` `userID` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `recordID`,
CHANGE `approvalType` `approvalType` varchar(50) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `groupID`,
CHANGE `comment` `comment` text COLLATE 'utf8mb3_general_ci' AFTER `time`,
COLLATE 'utf8mb3_general_ci';


UPDATE `settings` SET `data` = '2025020100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
