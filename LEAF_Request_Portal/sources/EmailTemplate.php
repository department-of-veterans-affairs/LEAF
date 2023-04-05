<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
 *  Email Template Handler
 */

namespace Portal;

class EmailTemplate
{
    private $db;

    private $login;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new \Leaf\DataActionLogger($db, $login);
    }

    /**
     * Summary of isEmailTemplateValid
     * @param string $template
     * @param array $list
     * @return bool
     */
    public function isEmailTemplateValid(string $template, array $list): bool
    {
        $validTemplate = false;
        foreach ($list as $item) {
            if ($template == $item['fileName']) {
                $validTemplate = true;
            }
        }
        return $validTemplate;
    }


    /**
     * Summary of getEmailData
     * @param string $template
     * @param bool $getStandard
     * @return array
     */
    public function getEmailData(string $template, bool $getStandard = false): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }

        $data = [];

        // If we have a body file, we need to add subject, emailTo, and emailCC template files
        if (preg_match('/_body.tpl$/', $template)) {
            // We have a body template (non-default) so grab what kind
            $emailKind = str_replace("_body.tpl", "", $template, $count);
            if ($count == 1) {
                $emailData = array('emailTo', 'emailCc', 'subject');

                foreach ($emailData as $dataType) {
                    $data[$dataType . 'FileName'] = $emailKind . '_' . $dataType . '.tpl';

                    if (file_exists("../templates/email/custom_override/{$data[$dataType . 'FileName']}") && !$getStandard)
                        $data[$dataType . 'File'] = file_get_contents("../templates/email/custom_override/{$data[$dataType . 'FileName']}");
                    else if (file_exists("../templates/email/{$data[$dataType . 'FileName']}"))
                        $data[$dataType . 'File'] = file_get_contents("../templates/email/{$data[$dataType . 'FileName']}");
                    else if (preg_match('/CustomEvent_/', $data[$dataType . 'FileName']) && $dataType === 'subject')
                        $data[$dataType . 'File'] = file_get_contents("../templates/email/base_templates/LEAF_template_subject.tpl");
                    else
                        $data[$dataType . 'File'] = '';
                }
            }
        }

        return $data;
    }

    /**
     * Summary of getEmailTemplate
     * @param string $template
     * @param bool $getStandard
     * @return array
     */
    public function getEmailTemplate(string $template, bool $getStandard = false): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }
        $list = $this->getEmailAndSubjectTemplateList();
        $data = [];
        $validTemplate = $this->isEmailTemplateValid($template, $list);
        if ($validTemplate) {
            if (
                file_exists("../templates/email/custom_override/{$template}")
                && !$getStandard
            ) {
                $data['modified'] = 1;
                $data['file'] = file_get_contents("../templates/email/custom_override/{$template}");
            } else {
                if (preg_match('/CustomEvent_/', $template)) {
                    $data['modified'] = 0;
                    $data['file'] = file_get_contents("../templates/email/base_templates/LEAF_template_body.tpl");
                } else {
                    $data['modified'] = 0;
                    $data['file'] = file_get_contents("../templates/email/{$template}");
                }
            }

            $res = $this->getEmailData($template, $getStandard);

            $emailInfo = ['emailTo', 'emailCc', 'subject'];
            foreach ($emailInfo as $infoType) {
                $data[$infoType . 'File'] = $res[$infoType . 'File'];
            }
        }

        return $data;
    }

    /**
     * Summary of getEmailTemplateFileHistory
     * @param string $templateFile
     * @return array
     */
    function getEmailTemplateFileHistory(string $templateFile): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }

        $vars = [
            ':template_file' => $templateFile
        ];
        $sql = 'SELECT file_id, file_parent_name, file_name, file_path, file_size, file_modify_by, file_created
                FROM `template_history_files`
                WHERE file_parent_name = :template_file
                ORDER BY `file_created` DESC';

        return $this->db->prepared_query($sql, $vars);
    }

    /**
     * Summary of getEmailAndSubjectTemplateList
     * @return array
     */
    public function getEmailAndSubjectTemplateList(): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['Admin access required'];
        }
        $out = [];
        $emailList = $this->db->query(
            'SELECT label, emailTo, emailCc, subject, body from email_templates ORDER BY emailTemplateID DESC'
        );
        foreach ($emailList as $listItem) {
            $data = [
                'displayName' => $listItem['label'],
                'fileName' => $listItem['body'],
                'emailToFileName' => $listItem['emailTo'],
                'emailCcFileName' => $listItem['emailCc'],
                'subjectFileName' => $listItem['subject']
            ];
            $out[] = $data;
        }
        return $out;
    }

    /**
     * Summary of getLabelFromFileName
     * @param string $fileName
     * @return string|null
     */
    public function getLabelFromFileName(string $fileName): ?string
    {
        $vars = [":body" => $fileName];
        $res = $this->db->prepared_query('SELECT label FROM email_templates WHERE body = :body', $vars);
        if ($res[0] != null) {
            return $res[0]["label"];
        }

        return null;
    }

    /**
     * Summary of getHistory
     * @param string $filterByName
     * @return array
     */
    public function getHistory(string $filterByName): array
    {
        $history = [];

        $fields = [
            'body' => \Leaf\LoggableTypes::EMAIL_TEMPLATE_BODY,
            'emailTo' => \Leaf\LoggableTypes::EMAIL_TEMPLATE_TO,
            'emailCc' => \Leaf\LoggableTypes::EMAIL_TEMPLATE_CC,
            'subject' => \Leaf\LoggableTypes::EMAIL_TEMPLATE_SUBJECT
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

    /**
     * Summary of setEmailTemplate
     * @param string $template
     * @return string|null
     */
    public function setEmailTemplate(string $template): ?string
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        $list = $this->getEmailAndSubjectTemplateList();
        $validTemplate = $this->isEmailTemplateValid($template, $list);

        if ($validTemplate) {
            $currentTemplate = $this->getEmailTemplate($template);
            $label = $this->getLabelFromFileName($template);

            // if the body has changed
            if ($currentTemplate['file'] !== $_POST['file']) {
                file_put_contents("../templates/email/custom_override/{$template}", $_POST['file']);

                $this->dataActionLogger->logAction(
                    \Leaf\DataActions::MODIFY,
                    \Leaf\LoggableTypes::EMAIL_TEMPLATE_BODY,
                    [new \Leaf\LogItem("email_templates", "body", $template, $label)]
                );
            }

            // if the subject is nonempty and has changed
            if (
                htmlentities($_POST['subjectFileName'], ENT_QUOTES) != ''
                && $currentTemplate['subjectFile'] !== $_POST['subjectFile']
            ) {
                file_put_contents("../templates/email/custom_override/" . $_POST['subjectFileName'], $_POST['subjectFile']);

                $this->dataActionLogger->logAction(
                    \Leaf\DataActions::MODIFY,
                    \Leaf\LoggableTypes::EMAIL_TEMPLATE_SUBJECT,
                    [new \Leaf\LogItem("email_templates", "subject", $template, $label)]
                );
            }

            // if emailTo is nonempty and has changed
            if (
                htmlentities($_POST['emailToFileName'], ENT_QUOTES) != ''
                && $currentTemplate['emailToFile'] !== $_POST['emailToFile']
            ) {
                file_put_contents("../templates/email/custom_override/" . $_POST['emailToFileName'], $_POST['emailToFile']);

                $this->dataActionLogger->logAction(
                    \Leaf\DataActions::MODIFY,
                    \Leaf\LoggableTypes::EMAIL_TEMPLATE_TO,
                    [new \Leaf\LogItem("email_templates", "emailTo", $template, $label)]
                );
            }

            // if emailCc is nonempty and has changed
            if (
                htmlentities($_POST['emailCcFileName'], ENT_QUOTES) != ''
                && $currentTemplate['emailCcFile'] !== $_POST['emailCcFile']
            ) {
                file_put_contents("../templates/email/custom_override/" . $_POST['emailCcFileName'], $_POST['emailCcFile']);

                $this->dataActionLogger->logAction(
                    \Leaf\DataActions::MODIFY,
                    \Leaf\LoggableTypes::EMAIL_TEMPLATE_CC,
                    [new \Leaf\LogItem("email_templates", "emailCc", $template, $label)]
                );
            }
        }

        return null;
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
        return "../templates_history/email_templates/{$fileName}";
    }

    /**
     * Summary of removeCustomEmailTemplate
     * @param string $template
     * @return string|null
     */
    public function removeCustomEmailTemplate(string $template): ?string
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $list = $this->getEmailAndSubjectTemplateList();
        $validTemplate = $this->isEmailTemplateValid($template, $list);
        if ($validTemplate) {
            if (file_exists("../templates/email/custom_override/{$template}")) {
                unlink("../templates/email/custom_override/{$template}");
            }

            $subjectFileName = htmlentities($_REQUEST['subjectFileName'], ENT_QUOTES);
            if ($subjectFileName != '' && file_exists("../templates/email/custom_override/{$subjectFileName}")) {
                unlink("../templates/email/custom_override/{$subjectFileName}");
            }
            $emailToFileName = htmlentities($_REQUEST['emailToFileName'], ENT_QUOTES);
            if ($emailToFileName != '' && file_exists("../templates/email/custom_override/{$emailToFileName}")) {
                unlink("../templates/email/custom_override/{$emailToFileName}");
            }
            $emailCcFileName = htmlentities($_REQUEST['emailCcFileName'], ENT_QUOTES);
            if ($emailCcFileName != '' && file_exists("../templates/email/custom_override/{$emailCcFileName}")) {
                unlink("../templates/email/custom_override/{$emailCcFileName}");
            }
        }
        return null;
    }
}
