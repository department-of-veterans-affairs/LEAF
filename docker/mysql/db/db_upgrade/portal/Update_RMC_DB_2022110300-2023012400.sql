START TRANSACTION;

UPDATE `indicators` SET `html` = '<div id=\"leafSecureDialogContent\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContent\');\n\n});\n</script>' WHERE `indicators`.`indicatorID` = -2;
UPDATE `indicators` SET `htmlPrint` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n});\n</script>' WHERE `indicators`.`indicatorID` = -2;

UPDATE `settings` SET `data` = '2023012400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

ALTER TABLE `workflow_steps` DROP COLUMN `stepData`;

DELETE FROM `email_templates` WHERE  `emailTemplateID`=-5;

ALTER TABLE `records_workflow_state` DROP COLUMN `lastNotified`;

UPDATE `settings` SET `data` = '2022050300' WHERE `settings`.`setting` = 'dbversion';


COMMIT;

*/
