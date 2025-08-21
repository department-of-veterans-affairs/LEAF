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
            return 'Admin access required';
        }

        $data = array();

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

    public function getEmailTemplate($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $list = $this->getEmailAndSubjectTemplateList();
        $data = array();
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

            $emailInfo = array('emailTo', 'emailCc', 'subject');
            foreach ($emailInfo as $infoType) {
                $data[$infoType . 'File'] = $res[$infoType . 'File'];
            }
        }

        return $data;
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
        $return_value = [];

        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        $list = scandir('../templates/email/custom_override');

        foreach ($list as $item) {
            if (preg_match('/.tpl$/', $item)) {
                $return_value[] = $item;
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
                    DataActions::MODIFY,
                    LoggableTypes::EMAIL_TEMPLATE_BODY,
                    [new LogItem("email_templates", "body", $template, $label)]
                );
            }

            // if the subject is nonempty and has changed
            if (
                htmlentities($_POST['subjectFileName'], ENT_QUOTES) != ''
                && $currentTemplate['subjectFile'] !== $_POST['subjectFile']
            ) {
                file_put_contents("../templates/email/custom_override/" . $_POST['subjectFileName'], $_POST['subjectFile']);

                $this->dataActionLogger->logAction(
                    DataActions::MODIFY,
                    LoggableTypes::EMAIL_TEMPLATE_SUBJECT,
                    [new LogItem("email_templates", "subject", $template, $label)]
                );
            }

            // if emailTo is nonempty and has changed
            if (
                htmlentities($_POST['emailToFileName'], ENT_QUOTES) != ''
                && $currentTemplate['emailToFile'] !== $_POST['emailToFile']
            ) {
                file_put_contents("../templates/email/custom_override/" . $_POST['emailToFileName'], $_POST['emailToFile']);

                $this->dataActionLogger->logAction(
                    DataActions::MODIFY,
                    LoggableTypes::EMAIL_TEMPLATE_TO,
                    [new LogItem("email_templates", "emailTo", $template, $label)]
                );
            }

            // if emailCc is nonempty and has changed
            if (
                htmlentities($_POST['emailCcFileName'], ENT_QUOTES) != ''
                && $currentTemplate['emailCcFile'] !== $_POST['emailCcFile']
            ) {
                file_put_contents("../templates/email/custom_override/" . $_POST['emailCcFileName'], $_POST['emailCcFile']);

                $this->dataActionLogger->logAction(
                    DataActions::MODIFY,
                    LoggableTypes::EMAIL_TEMPLATE_CC,
                    [new LogItem("email_templates", "emailCc", $template, $label)]
                );
            }
        }
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

    public function removeCustomEmailTemplate($template)
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        # path to be used for the rest of the 
        $customOverrideABS = XSSHelpers::absolutePath("../templates/email/custom_override/");

        if($customOverrideABS == false){
            return 'Invalid file directory';
        }

        $list = $this->getEmailAndSubjectTemplateList();
        $validTemplate = $this->isEmailTemplateValid($template, $list);
        if ($validTemplate) {
            if (file_exists($customOverrideABS."{$template}")) {
                unlink($customOverrideABS."{$template}");
                $this->dataActionLogger->logAction(
                    DataActions::RESTORE,
                    LoggableTypes::EMAIL_TEMPLATE_BODY,
                    [new LogItem("email_templates", "body", $template, $template)]
                );
            }

            $subjectFileName = htmlentities($_REQUEST['subjectFileName'], ENT_QUOTES);
            if ($subjectFileName != '' && file_exists($customOverrideABS."{$subjectFileName}")) {
                unlink($customOverrideABS."{$subjectFileName}");
            }
            $emailToFileName = htmlentities($_REQUEST['emailToFileName'], ENT_QUOTES);
            if ($emailToFileName != '' && file_exists($customOverrideABS."{$emailToFileName}")) {
                unlink($customOverrideABS."{$emailToFileName}");
            }
            $emailCcFileName = htmlentities($_REQUEST['emailCcFileName'], ENT_QUOTES);
            if ($emailCcFileName != '' && file_exists($customOverrideABS."{$emailCcFileName}")) {
                unlink($customOverrideABS."{$emailCcFileName}");
            }
        }
    }
}
