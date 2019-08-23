START TRANSACTION;

INSERT INTO `categories` (`categoryID`, `parentID`, `categoryName`, `categoryDescription`, `workflowID`, `sort`, `needToKnow`, `formLibraryID`, `visible`, `disabled`, `type`) VALUES ('leaf_secure', '', 'Leaf Secure Certification', '', '0', '0', '0', NULL, '1', '0', '');
ALTER TABLE `workflow_steps` DROP FOREIGN KEY workflow_steps_ibfk_1;
ALTER TABLE `workflow_steps` CHANGE `workflowID` `workflowID` SMALLINT NOT NULL;
ALTER TABLE `workflow_routes` DROP FOREIGN KEY workflow_routes_ibfk_1;
ALTER TABLE `workflow_routes` CHANGE `workflowID` `workflowID` SMALLINT NOT NULL;
ALTER TABLE `workflow_routes` CHANGE `nextStepID` `nextStepID` SMALLINT NOT NULL;
ALTER TABLE `workflows` CHANGE `workflowID` `workflowID` SMALLINT NOT NULL AUTO_INCREMENT;
ALTER TABLE `route_events` CHANGE `workflowID` `workflowID` SMALLINT NOT NULL;
ALTER TABLE `records_workflow_state` CHANGE `stepID` `stepID` SMALLINT NOT NULL;
ALTER TABLE `workflow_steps` ADD CONSTRAINT `workflow_steps_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows`(`workflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `workflow_routes` ADD CONSTRAINT `workflow_routes_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows`(`workflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE `categories` CHANGE `workflowID` `workflowID` SMALLINT NOT NULL;

INSERT INTO `workflows` (`workflowID`, `initialStepID`, `description`) VALUES ('-1', '0', 'LEAF Secure Certification');
INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `htmlPrint`, `jsSort`, `required`, `sort`, `timeAdded`, `disabled`, `is_sensitive`) VALUES ('-1', 'Privacy Officer', 'orgchart_employee', NULL, NULL, NULL, 'leaf_secure', NULL, NULL, NULL, '1', '1', current_timestamp(), '0', '0');
INSERT INTO `workflow_steps` (`workflowID`, `stepID`, `stepTitle`, `stepBgColor`, `stepFontColor`, `stepBorder`, `jsSrc`, `posX`, `posY`, `indicatorID_for_assigned_empUID`, `indicatorID_for_assigned_groupID`, `requiresDigitalSignature`) VALUES
(-1, -3, 'Supervisory Review for LEAF-S Certification', '#82b9fe', 'black', '1px solid black', '', 579, 146, -4, NULL, NULL),
(-1, -2, 'Privacy Officer Review for LEAF-S Certification', '#82b9fe', 'black', '1px solid black', '', 575, 331, -1, NULL, NULL);
UPDATE `workflows` SET `initialStepID` = '-3' WHERE `workflows`.`workflowID` = -1;
INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`, `actionType`, `displayConditional`) VALUES ('-1', '-3', '-2', 'approve', '');
INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`, `actionType`, `displayConditional`) VALUES ('-1', '-3', '0', 'sendback', '');
INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`, `actionType`, `displayConditional`) VALUES ('-1', '-2', '0', 'approve', '');
INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`, `actionType`, `displayConditional`) VALUES ('-1', '-2', '0', 'sendback', '');
INSERT INTO `step_dependencies` (`stepID`, `dependencyID`) VALUES ('-2', '-1');
INSERT INTO `step_dependencies` (`stepID`, `dependencyID`) VALUES ('-3', '-1');
UPDATE `categories` SET `workflowID` = '-1' WHERE `categories`.`categoryID` = 'leaf_secure';
INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `htmlPrint`, `jsSort`, `required`, `sort`, `timeAdded`, `disabled`, `is_sensitive`) VALUES ('-2', 'Justification for collection of sensitive data', 'text', NULL, NULL, NULL, 'leaf_secure', NULL, NULL, NULL, '0', '1', current_timestamp(), '0', '0');
UPDATE `indicators` SET `sort` = '2' WHERE `indicators`.`indicatorID` = -2;
ALTER TABLE `indicators` CHANGE `parentID` `parentID` SMALLINT NULL DEFAULT NULL;
UPDATE `indicators` SET `required` = '1' WHERE `indicators`.`indicatorID` = -2;
UPDATE `indicators` SET `format` = 'textarea' WHERE `indicators`.`indicatorID` = -2;

INSERT INTO `events` (`eventID`, `eventDescription`, `eventData`) VALUES ('LeafSecure_Certified', 'Marks site as LEAF Secure', '');
INSERT INTO `route_events` (`workflowID`, `stepID`, `actionType`, `eventID`) VALUES
(-1, -3, 'approve', 'std_email_notify_next_approver'),
(-1, -2, 'approve', 'LeafSecure_Certified'),
(-1, -2, 'approve', 'std_email_notify_completed'),
(-1, -1, 'submit', 'std_email_notify_next_approver');

INSERT INTO `settings` (`setting`, `data`) VALUES ('leafSecure', '0');

UPDATE `settings` SET `data` = '2019081600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
