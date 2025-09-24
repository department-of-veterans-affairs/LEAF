START TRANSACTION;

UPDATE `indicators` SET
`html` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n\n    function validateForm() {\n\n      if (textArea.value.length < minLength) {\n        // Display error message\n        errorMessage.textContent = `Please provide a more detailed justification. Minimum ${minLength} characters required. `;\n        $(\'.nextQuestion\').off(\'click\');\n        $(\'.nextQuestion\').on(\'click\',function() {\n            $(\'#-2_required\').addClass(\'input-required-error\');\n        });\n\n      } else {\n        errorMessage.textContent = \"\"; //Clear the error message if valid.\n        $(\'#-2_required\').removeClass(\'input-required-error\');\n\n        $(\'.nextQuestion\').off(\'click\');\n        $(\'.nextQuestion\').on(\'click\',function() {\n            form.dialog().indicateBusy();\n            form.setPostModifyCallback(function() {\n                getNext();\n                updateProgress(true);\n            });\n            form.dialog().clickSave();\n        });\n      }\n    }\n\n    $(\'.nextQuestion\').off(\'click\');\n    \n    // Optional: Real-time character count and feedback (improves user experience)\n    const textArea = document.getElementById(\'-2\');\n    const errorMessage = document.getElementById(\'-2_required\'); //Element to display character count\n    const minLength = 25;\n    validateForm();\n\n    textArea.addEventListener(\'input\', function() {\n      validateForm();\n    });\n\n});\n</script>'
WHERE `indicatorID` = '-2';
UPDATE `settings` SET `data` = '2025091200' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;
UPDATE `indicators` SET

`html` = '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n\n\n});\n</script>'

WHERE `indicatorID` = '-2';
UPDATE `settings` SET `data` = '2025081400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
