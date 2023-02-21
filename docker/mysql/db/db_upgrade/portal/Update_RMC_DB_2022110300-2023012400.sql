START TRANSACTION;

UPDATE `indicators` SET `html` = '<div id=\"leafSecureDialogContent\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContent\');\n\n});\n</script>' WHERE `indicators`.`indicatorID` = -2;
UPDATE `indicators` SET `htmlPrint` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n});\n</script>' WHERE `indicators`.`indicatorID` = -2;

UPDATE `settings` SET `data` = '2023012400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

UPDATE `indicators` SET `html` = '<div id=\"leafSecureDialogContent\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\" />\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContent\');\n\n});\n</script>' WHERE `indicators`.`indicatorID` = -2;
UPDATE `indicators` SET `htmlPrint` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\" />\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n});\n</script>' WHERE `indicators`.`indicatorID` = -2;

UPDATE `settings` SET `data` = '2022110300' WHERE `settings`.`setting` = 'dbversion';


COMMIT;

*/
