START TRANSACTION;
UPDATE `indicators` SET
`indicatorID` = '-2',
`name` = 'Justification for collection of sensitive data',
`format` = 'textarea',
`description` = '',
`default` = '',
`parentID` = NULL,
`categoryID` = 'leaf_secure',
`html` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n\n    function validateForm() {\n\n      if (textArea.value.length < minLength) {\n        // Display error message\n        errorMessage.textContent = `Please provide a more detailed justification. Minimum ${minLength} characters required. `;\n        //return false; // Return false to indicate validation failure\n        $(\'.nextQuestion\').off(\'click\');\n      } else {\n        errorMessage.textContent = \"\"; //Clear the error message if valid.\n        //return true; // Return true to allow form submission\n        $(\'.nextQuestion\').on(\'click\',function() {\n            form.dialog().indicateBusy();\n            form.setPostModifyCallback(function() {\n                getNext();\n                updateProgress(true);\n            });\n            form.dialog().clickSave();\n        });\n      }\n    }\n    $(\'.nextQuestion\').off(\'click\');\n    \n    // Optional: Real-time character count and feedback (improves user experience)\n    const textArea = document.getElementById(\'-2\');\n    const errorMessage = document.getElementById(\'-2_required\'); //Element to display character count\n    const minLength = 25;\n    validateForm();\n\n    textArea.addEventListener(\'input\', function() {\n      validateForm();\n    });\n\n});\n</script>',
`htmlPrint` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n\n\n});\n</script>',
`conditions` = NULL,
`jsSort` = NULL,
`required` = '1',
`sort` = '2',
`timeAdded` = '2019-07-30 20:25:06',
`disabled` = '0',
`is_sensitive` = '0'
WHERE `indicatorID` = '-2';

COMMIT;

/**** Revert DB *****
START TRANSACTION;
UPDATE `indicators` SET
`indicatorID` = '-2',
`name` = 'Justification for collection of sensitive data',
`format` = 'textarea',
`description` = '',
`default` = '',
`parentID` = NULL,
`categoryID` = 'leaf_secure',
`html` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n\n\n});\n</script>',
`htmlPrint` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n\n\n});\n</script>',
`conditions` = NULL,
`jsSort` = NULL,
`required` = '1',
`sort` = '2',
`timeAdded` = '2019-07-30 20:25:06',
`disabled` = '0',
`is_sensitive` = '0'
WHERE `indicatorID` = '-2';

COMMIT;
*/
