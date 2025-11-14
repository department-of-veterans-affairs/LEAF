<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
 *  Email Template Handler
 */

namespace Portal;

use App\Leaf\Logger\DataActionLogger;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;
use App\Leaf\XSSHelpers;

class EmailTemplate
{
    private $db;

    private $login;

    private $dataActionLogger;

    private const EMAIL_TEMPLATE_DIR = '../templates/email';
    private const CUSTOM_OVERRIDE_DIR = '../templates/email/custom_override';
    private const TEMPLATE_HISTORY_DIR = '../templates_history/email_templates';
    private const BASE_TEMPLATES_DIR = '../templates/email/base_templates';

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new DataActionLogger($db, $login);
    }

    public function isEmailTemplateValid($template, $list)
    {
        $validTemplate = false;

        foreach ($list as $item) {
            if ($template == $item['fileName']) {
                $validTemplate = true;
            }
        }

        return $validTemplate;
    }

    public function getEmailData($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required';
        } else {
            $template = XSSHelpers::scrubFilename($template);
            $template = XSSHelpers::removeMultipleDots($template);

            $return_value = array();

            // If we have a body file, we need to add subject, emailTo, and emailCC template files
            if (preg_match('/_body.tpl$/', $template)) {
                // We have a body template (non-default) so grab what kind
                $emailKind = str_replace("_body.tpl", "", $template, $count);
                if ($count == 1) {
                    $emailData = array('emailTo', 'emailCc', 'subject');

                    foreach ($emailData as $dataType) {
                        $return_value[$dataType . 'FileName'] = $emailKind . '_' . $dataType . '.tpl';

                        if (file_exists(self::CUSTOM_OVERRIDE_DIR . "/{$return_value[$dataType . 'FileName']}") && !$getStandard)
                            $return_value[$dataType . 'File'] = file_get_contents(self::CUSTOM_OVERRIDE_DIR . "/{$return_value[$dataType . 'FileName']}");
                        else if (file_exists(self::EMAIL_TEMPLATE_DIR . "/{$return_value[$dataType . 'FileName']}"))
                            $return_value[$dataType . 'File'] = file_get_contents(self::EMAIL_TEMPLATE_DIR . "/{$return_value[$dataType . 'FileName']}");
                        else if (preg_match('/CustomEvent_/', $return_value[$dataType . 'FileName']) && $dataType === 'subject')
                            $return_value[$dataType . 'File'] = file_get_contents(self::BASE_TEMPLATES_DIR . "/LEAF_template_subject.tpl");
                        else
                            $return_value[$dataType . 'File'] = '';
                    }
                }
            }
        }

        return $return_value;
    }

    public function getEmailTemplate($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required';
        } else {
            $template = XSSHelpers::scrubFilename($template);
            $template = XSSHelpers::removeMultipleDots($template);

            $list = $this->getEmailAndSubjectTemplateList();
            $return_value = array();
            $validTemplate = $this->isEmailTemplateValid($template, $list);

            if ($validTemplate) {
                if (
                    file_exists(self::CUSTOM_OVERRIDE_DIR . "/{$template}")
                    && !$getStandard
                ) {
                    $return_value['modified'] = 1;
                    $return_value['file'] = file_get_contents(self::CUSTOM_OVERRIDE_DIR . "/{$template}");
                } else {
                    if (preg_match('/CustomEvent_/', $template)) {
                        $return_value['modified'] = 0;
                        $return_value['file'] = file_get_contents(self::BASE_TEMPLATES_DIR . "/LEAF_template_body.tpl");
                    } else {
                        $return_value['modified'] = 0;
                        $return_value['file'] = file_get_contents(self::EMAIL_TEMPLATE_DIR . "/{$template}");
                    }
                }

                $res = $this->getEmailData($template, $getStandard);

                $emailInfo = array('emailTo', 'emailCc', 'subject');
                foreach ($emailInfo as $infoType) {
                    $return_value[$infoType . 'File'] = $res[$infoType . 'File'];
                }
            }
        }

        return $return_value;
    }

    public function getEmailAndSubjectTemplateList()
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $out = array();
        $emailList = $this->db->query(
            'SELECT label, emailTo, emailCc, subject, body from email_templates WHERE emailTemplateID != 1 ORDER BY emailTemplateID DESC'
        );
        foreach ($emailList as $listItem) {
            $data = array(
                'displayName' => $listItem['label'],
                'fileName' => $listItem['body'],
                'emailToFileName' => $listItem['emailTo'],
                'emailCcFileName' => $listItem['emailCc'],
                'subjectFileName' => $listItem['subject']
            );
            $out[] = $data;
        }
        return $out;
    }

    /**
     * getCustomEmailTemplateList retrieves a list of custom email templates
     * @return array of templates
     * @return string error message
     *
     * Created at: 6/6/2023, 1:40:09 PM (America/New_York)
     */
    public function getCustomEmailTemplateList(): array|string
    {
        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required';
        } else {
            $list = scandir(self::CUSTOM_OVERRIDE_DIR);
            $return_value = [];

            foreach ($list as $item) {
                if (preg_match('/.tpl$/', $item)) {
                    $return_value[] = $item;
                }
            }
        }

        return $return_value;
    }

    public function getLabelFromFileName($fileName)
    {
        $vars = [":body" => $fileName];
        $res = $this->db->prepared_query('SELECT label FROM email_templates WHERE body = :body', $vars);
        if ($res[0] != null) {
            return $res[0]["label"];
        }

        return;
    }

    public function getHistory($filterByName)
    {
        $history = [];

        $fields = [
            'body' => LoggableTypes::EMAIL_TEMPLATE_BODY,
            'emailTo' => LoggableTypes::EMAIL_TEMPLATE_TO,
            'emailCc' => LoggableTypes::EMAIL_TEMPLATE_CC,
            'subject' => LoggableTypes::EMAIL_TEMPLATE_SUBJECT
        ];

        foreach ($fields as $field => $type) {
            $fieldHistory = $this->dataActionLogger->getHistory($filterByName, $field, $type);
            $history = array_merge($history, $fieldHistory);
        }

        usort($history, function ($a, $b) {
            return $a['timestamp'] <=> $b['timestamp'];
        });

        return $history;
    }

    public function setEmailTemplate($template)
    {
        $return_value = '';

        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required';
        } else {
            $template = XSSHelpers::scrubFilename($template);
            $template = XSSHelpers::removeMultipleDots($template);

            $list = $this->getEmailAndSubjectTemplateList();
            $validTemplate = $this->isEmailTemplateValid($template, $list);

            if ($validTemplate && $this->isValidTemplateExtension($template)) {
                $currentTemplate = $this->getEmailTemplate($template);
                $label = $this->getLabelFromFileName($template);

                $baseDir = realpath(self::CUSTOM_OVERRIDE_DIR);

                if ($baseDir) {
                    if (isset($_POST['file']) && $currentTemplate['file'] !== $_POST['file']) {
                        $filePath = $baseDir . '/' . $template;

                        if ($this->isPathSafe($filePath, $baseDir)) {
                            if (file_put_contents($filePath, $_POST['file'])) {
                                $this->dataActionLogger->logAction(
                                    DataActions::MODIFY,
                                    LoggableTypes::EMAIL_TEMPLATE_BODY,
                                    [new LogItem("email_templates", "body", $template, $label)]
                                );
                            } else {
                                $return_value = 'Failed to write template file';
                            }
                        } else {
                            $return_value = 'Invalid file path';
                        }
                    }

                    // if the subject is nonempty and has changed
                    if (
                        !empty($_POST['subjectFileName']) &&
                        htmlentities($_POST['subjectFileName'], ENT_QUOTES) != '' &&
                        isset($_POST['subjectFile']) &&
                        $currentTemplate['subjectFile'] !== $_POST['subjectFile']
                    ) {
                        $subjectFileName = XSSHelpers::scrubFilename($_POST['subjectFileName']);
                        $subjectFileName = XSSHelpers::removeMultipleDots($subjectFileName);

                        if ($this->isValidTemplateExtension($subjectFileName)) {
                            $filePath = $baseDir . '/' . $subjectFileName;

                            if ($this->isPathSafe($filePath, $baseDir)) {
                                if (file_put_contents($filePath, $_POST['subjectFile'])) {
                                    $this->dataActionLogger->logAction(
                                        DataActions::MODIFY,
                                        LoggableTypes::EMAIL_TEMPLATE_SUBJECT,
                                        [new LogItem("email_templates", "subject", $template, $label)]
                                    );
                                } else {
                                    $return_value = 'Failed to write subject file';
                                }
                            } else {
                                $return_value = 'Invalid subject file path';
                            }
                        } else {
                            $return_value = 'Invalid subject file extension';
                        }
                    }

                    // if emailTo is nonempty and has changed
                    if (
                        !empty($_POST['emailToFileName']) &&
                        htmlentities($_POST['emailToFileName'], ENT_QUOTES) != '' &&
                        isset($_POST['emailToFile']) &&
                        $currentTemplate['emailToFile'] !== $_POST['emailToFile']
                    ) {
                        $emailToFileName = XSSHelpers::scrubFilename($_POST['emailToFileName']);
                        $emailToFileName = XSSHelpers::removeMultipleDots($emailToFileName);

                        if ($this->isValidTemplateExtension($emailToFileName)) {
                            $filePath = $baseDir . '/' . $emailToFileName;

                            if ($this->isPathSafe($filePath, $baseDir)) {
                                if (file_put_contents($filePath, $_POST['emailToFile'])) {
                                    $this->dataActionLogger->logAction(
                                        DataActions::MODIFY,
                                        LoggableTypes::EMAIL_TEMPLATE_TO,
                                        [new LogItem("email_templates", "emailTo", $template, $label)]
                                    );
                                } else {
                                    $return_value = 'Failed to write emailTo file';
                                }
                            } else {
                                $return_value = 'Invaild emailTo file path';
                            }
                        } else {
                            $return_value = 'Invalid emailTo file extension';
                        }
                    }

                    // if emailCc is nonempty and has changed
                    if (
                        !empty($_POST['emailCcFileName']) &&
                        htmlentities($_POST['emailCcFileName'], ENT_QUOTES) != '' &&
                        isset($_POST['emailCcFile']) &&
                        $currentTemplate['emailCcFile'] !== $_POST['emailCcFile']
                    ) {
                        $emailCcFileName = XSSHelpers::scrubFilename($_POST['emailCcFileName']);
                        $emailCcFileName = XSSHelpers::removeMultipleDots($emailCcFileName);

                        if ($this->isValidTemplateExtension($emailCcFileName)) {
                            $filePath = $baseDir . '/' . $emailCcFileName;

                            if ($this->isPathSafe($filePath, $baseDir)) {
                                if (file_put_contents($filePath, $_POST['emailCcFile'])) {
                                    $this->dataActionLogger->logAction(
                                        DataActions::MODIFY,
                                        LoggableTypes::EMAIL_TEMPLATE_CC,
                                        [new LogItem("email_templates", "emailCc", $template, $label)]
                                    );
                                } else {
                                    $return_value = 'Failed to write emailCc file';
                                }
                            } else {
                                $return_value = 'Invalid emailCc file path';
                            }
                        } else {
                            $return_value = 'Invalid emailCc file extension';
                        }
                    }
                } else {
                    $return_value = 'Template directory not found';
                }
            } else {
                $return_value = 'Invalid template';
            }
        }

        return $return_value;
    }

    /**
     * Summary of setHistoryEmailTemplate
     * @param string $template
     * @return string
     */
    public function setHistoryEmailTemplate(string $template): string
    {
        // Check if user is authorized to modify email templates
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        // Get list of available email templates
        $availableTemplates = $this->getEmailAndSubjectTemplateList();

        // Check if the specified email template is valid
        $validTemplate = $this->isEmailTemplateValid($template, $availableTemplates);

        if (!$validTemplate) {
            return 'Invalid email template';
        }

        $time = date("Y-m-d h:i:s");
        $templateID = uniqid();

        // Update email body file
        if (!empty($_POST['file'])) {
            $fileData = $_POST['file'];
            $fileName = "{$templateID}_{$template}";
            $filePath = $this->getTemplateFilePath($fileName);

            if (!file_put_contents($filePath, $fileData)) {
                return 'Failed to update email template';
            }

            $fileSize = filesize($filePath);
            $this->dataActionLogger->logTemplateFileHistory($fileName, $template, $filePath, $fileSize, $time);
        }

        // Update email subject file
        if (!empty($_POST['subjectFile'])) {
            $subjectFileName = "{$templateID}_" . $_POST['subjectFileName'];
            $subjectFile = $_POST['subjectFile'];
            $filePath = $this->getTemplateFilePath($subjectFileName);

            if (!file_put_contents($filePath, $subjectFile)) {
                return 'Failed to update email template subject';
            }

            $fileSize = filesize($filePath);
            $this->dataActionLogger->logTemplateFileHistory($subjectFileName, $_POST['subjectFileName'], $filePath, $fileSize, $time);
        }

        // Update emailTo file
        if (!empty($_POST['emailToFile'])) {
            $emailToFileName = "{$templateID}_" . $_POST['emailToFileName'];
            $emailToFile = $_POST['emailToFile'];
            $filePath = $this->getTemplateFilePath($emailToFileName);

            if (!file_put_contents($filePath, $emailToFile)) {
                return 'Failed to update email template emailTo';
            }

            $fileSize = filesize($filePath);
            $this->dataActionLogger->logTemplateFileHistory($emailToFileName, $_POST['emailToFileName'], $filePath, $fileSize, $time);
        }

        // Update emailCc file
        if (!empty($_POST['emailCcFile'])) {
            $emailCCFileName = "{$templateID}_" . $_POST['emailCcFileName'];
            $emailCCFile = $_POST['emailCcFile'];
            $filePath = $this->getTemplateFilePath($emailCCFileName);

            if (!file_put_contents($filePath, $emailCCFile)) {
                return 'Failed to update email template emailCc';
            }

            $fileSize = filesize($filePath);
            $this->dataActionLogger->logTemplateFileHistory($emailCCFileName, $_POST['emailCcFileName'], $filePath, $fileSize, $time);
        }

        return 'Email template updated successfully';
    }

    /**
     * Summary of getTemplateFilePath
     * @param string $fileName
     * @return string
     */
    private function getTemplateFilePath(string $fileName): string
    {
        $fileName = XSSHelpers::scrubFilename($fileName);
        $fileName = XSSHelpers::removeMultipleDots($fileName);

        if (!$this->isValidTemplateExtension($fileName)) {
            throw new \Exception('Invalid template file extension');
        }

        $baseDir = realpath(self::TEMPLATE_HISTORY_DIR);

        if ($baseDir === false) {
            throw new \Exception('Template history directory not found');
        }

        $filePath = $baseDir . '/' . $fileName;

        if (!$this->isPathSafe($filePath, $baseDir)) {
            throw new \Exception('Invalid file path');
        }

        return $filePath;
    }

    public function removeCustomEmailTemplate($template)
    {
        $return_value = '';

        if (!$this->login->checkGroup(1)) {
            $return_value = 'Admin access required';
        } else {
            $list = $this->getEmailAndSubjectTemplateList();
            $validTemplate = $this->isEmailTemplateValid($template, $list);

            if ($validTemplate) {
                $baseDir = realpath(self::CUSTOM_OVERRIDE_DIR);

                if ($baseDir) {
                    $templatePath = $baseDir . '/' . $template;

                    if ($this->isPathSafe($templatePath, $baseDir) && file_exists($templatePath)) {
                        unlink($templatePath);
                        $this->dataActionLogger->logAction(
                            DataActions::RESTORE,
                            LoggableTypes::EMAIL_TEMPLATE_BODY,
                            [new LogItem("email_templates", "body", $template, $template)]
                        );
                    }

                    $subjectFileName = XSSHelpers::scrubFilename($_REQUEST['subjectFileName']);
                    $subjectFileName = XSSHelpers::removeMultipleDots($subjectFileName);

                    if ($subjectFileName != '') {
                        $subjectPath = $baseDir . '/' . $subjectFileName;

                        if ($this->isPathSafe($subjectPath, $baseDir)  && file_exists($subjectPath)) {
                            unlink($subjectPath);
                        }
                    }

                    $emailToFileName = XSSHelpers::scrubFilename($_REQUEST['emailToFileName']);
                    $emailToFileName = XSSHelpers::removeMultipleDots($emailToFileName);

                    if ($emailToFileName != '') {
                        $emailToPath = $baseDir . '/' . $emailToFileName;

                        if ($this->isPathSafe($emailToPath, $baseDir)  && file_exists($emailToPath)) {
                            unlink($emailToPath);
                        }

                    }

                    $emailCcFileName = XSSHelpers::scrubFilename($_REQUEST['emailCcFileName']);
                    $emailCcFileName = XSSHelpers::removeMultipleDots($emailCcFileName);

                    if ($emailCcFileName != '') {
                        $emailCcPath = $baseDir . '/' . $emailCcFileName;

                        if ($this->isPathSafe($emailCcPath, $baseDir)  && file_exists($emailCcPath)) {
                            unlink($emailCcPath);
                        }
                    }
                } else {
                    $return_value = 'Template directory not found';
                }
            } else {
                $return_value = 'Invalid template';
            }
        }

        return $return_value;
    }

    /**
     * Validates that a file path is within the allowed directory
     * Prevents path traversal attacks
     * @param string $filePath
     * @param string $allowedDirectory
     * @return bool
     */
    private function isPathSafe(string $filePath, string $allowedDirectory): bool
    {
        $realPath = realpath(dirname($filePath));
        $realAllowedPath = realpath($allowedDirectory);

        // If path doesn't exist yet, check the parent directory
        if ($realPath === false) {
            $realPath = realpath(dirname(dirname($filePath)));
        }

        // Ensure the resolved path starts with the allowed directory
        return $realPath !== false &&
            $realAllowedPath !== false &&
            strpos($realPath, $realAllowedPath) === 0;
    }

    /**
     * Validates template file extension
     * @param string $fileName
     * @return bool
     */
    private function isValidTemplateExtension(string $fileName): bool
    {
        return preg_match('/^[a-zA-Z0-9_-]+\.tpl$/', $fileName) === 1;
    }
}
