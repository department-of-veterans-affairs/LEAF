<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
 *  Email Template Handler
 */

if(!class_exists('DataActionLogger'))
{
    require_once dirname(__FILE__) . '/../../libs/logger/dataActionLogger.php';
}

class EmailTemplate
{
    private $db;

    private $login;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new \DataActionLogger($db, $login);
    }

    public function isEmailTemplateValid($template, $list) {
        $validTemplate = false;
        foreach ($list as $item) {
            if ($template == $item['fileName']) {
                $validTemplate = true;
            }
        }
        return $validTemplate;
    }

    public function getID($bodyFilename) {
        $vars = [":"];
    }

    public function getEmailData($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        $data = array();

        // If we have a body file, we need to add subject, emailTo, and emailCC template files
        if (preg_match('/_body.tpl$/', $template))
        {
            // We have a body template (non-default) so grab what kind
            $emailKind = str_replace("_body.tpl", "", $template, $count);
            if ($count == 1)
            {
                $emailData = array('emailTo', 'emailCc', 'subject');

                foreach ($emailData as $dataType) {
                    $data[$dataType.'FileName'] = $emailKind.'_'.$dataType.'.tpl';

                    if (file_exists("../templates/email/custom_override/{$data[$dataType.'FileName']}") && !$getStandard)
                        $data[$dataType.'File'] = file_get_contents("../templates/email/custom_override/{$data[$dataType.'FileName']}");
                    else if (file_exists("../templates/email/{$data[$dataType.'FileName']}"))
                        $data[$dataType.'File'] = file_get_contents("../templates/email/{$data[$dataType.'FileName']}");
                    else if (preg_match('/CustomEvent_/', $data[$dataType.'FileName']) && $dataType === 'subject')
                        $data[$dataType.'File'] = file_get_contents("../templates/email/base_templates/LEAF_template_subject.tpl");
                    else
                        $data[$dataType.'File'] = '';
                }
            }
        }

        return $data;
    }

    public function getEmailTemplate($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailAndSubjectTemplateList();
        $data = array();
        $validTemplate = $this->isEmailTemplateValid($template, $list);
        if ($validTemplate)
        {
            if (file_exists("../templates/email/custom_override/{$template}")
                  && !$getStandard)
            {
                $data['modified'] = 1;
                $data['file'] = file_get_contents("../templates/email/custom_override/{$template}");
            }
            else
            {
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
            foreach($emailInfo as $infoType) {
                $data[$infoType.'File'] = $res[$infoType.'File'];
            }
        }

        return $data;
    }

    public function getEmailAndSubjectTemplateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $out = array();
        $emailList = $this->db->query(
            'SELECT label, emailTo, emailCc, subject, body from email_templates ORDER BY emailTemplateID DESC'
        );
        foreach($emailList as $listItem) {
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

    public function getLabel($emailTemplateID)
    {
        $vars = [":emailTemplateID" => $emailTemplateID];
        $res = $this->db->prepared_query('SELECT * FROM `email_templates` WHERE emailTemplateID = :emailTemplateID', $vars);
        if($res[0] != null){
            return $res[0]["label"];
        }
        return;
    }

    public function getHistory($filterByName)
    {
        $history = [];
        
        $fields = [
            'body' => \LoggableTypes::EMAIL_TEMPLATE_BODY,
            'emailTo' => \LoggableTypes::EMAIL_TEMPLATE_TO,
            'emailCc' => \LoggableTypes::EMAIL_TEMPLATE_CC,
            'subject' => \LoggableTypes::EMAIL_TEMPLATE_SUBJECT
        ];

        foreach ($fields as $field => $type) {
            $fieldHistory = $this->dataActionLogger->getHistory($filterByName, $field, $type);
            $history = array_merge($history, $fieldHistory);
        }

        usort($history, function($a, $b) {
            return $a['timestamp'] <=> $b['timestamp'];
        });

        return $history;
    }

    public function setEmailTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }

        var_dump($_POST);die;

        $list = $this->getEmailAndSubjectTemplateList();
        $validTemplate = $this->isEmailTemplateValid($template, $list);
        $currentTemplate = $this->getEmailTemplate($template);

        if ($validTemplate)
        {
            // if the body has changed
            if ($currentTemplate['file'] !== $_POST['file']) {
                file_put_contents("../templates/email/custom_override/{$template}", $_POST['file']);

                $this->dataActionLogger->logAction(
                    \DataActions::MODIFY,
                    \LoggableTypes::EMAIL_TEMPLATE_BODY,
                    [new LogItem("email_templates", "body", $template)]
                );
            }

            // if the subject is nonempty and has changed
            if (htmlentities($_POST['subjectFileName'], ENT_QUOTES) != ''
                && $currentTemplate['subjectFile'] !== $_POST['subjectFile']) {
                file_put_contents("../templates/email/custom_override/" . $_POST['subjectFileName'], $_POST['subjectFile']);
                
                $this->dataActionLogger->logAction(
                    \DataActions::MODIFY,
                    \LoggableTypes::EMAIL_TEMPLATE_SUBJECT,
                    [new LogItem("email_templates", "subject", $template)]
                );
            }

            // if emailTo is nonempty and has changed
            if (htmlentities($_POST['emailToFileName'], ENT_QUOTES) != ''
                && $currentTemplate['emailToFile'] !== $_POST['emailToFile']) {
                file_put_contents("../templates/email/custom_override/" . $_POST['emailToFileName'], $_POST['emailToFile']);
                
                $this->dataActionLogger->logAction(
                    \DataActions::MODIFY,
                    \LoggableTypes::EMAIL_TEMPLATE_TO,
                    [new LogItem("email_templates", "emailTo", $template)]
                );
            }

            // if emailCc is nonempty and has changed
            if (htmlentities($_POST['emailCcFileName'], ENT_QUOTES) != ''
                && $currentTemplate['emailCcFile'] !== $_POST['emailCcFile']) {
                file_put_contents("../templates/email/custom_override/" . $_POST['emailCcFileName'], $_POST['emailCcFile']);
                
                $this->dataActionLogger->logAction(
                    \DataActions::MODIFY,
                    \LoggableTypes::EMAIL_TEMPLATE_CC,
                    [new LogItem("email_templates", "emailCc", $template)]
                );
            }
        }
    }

    public function removeCustomEmailTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getEmailAndSubjectTemplateList();
        $validTemplate = $this->isEmailTemplateValid($template, $list);
        if ($validTemplate)
        {
            if (file_exists("../templates/email/custom_override/{$template}"))
            {
                unlink("../templates/email/custom_override/{$template}");
            }

            $subjectFileName = htmlentities($_REQUEST['subjectFileName'], ENT_QUOTES);
            if ($subjectFileName != '' && file_exists("../templates/email/custom_override/{$subjectFileName}"))
            {
                unlink("../templates/email/custom_override/{$subjectFileName}");
            }
            $emailToFileName = htmlentities($_REQUEST['emailToFileName'], ENT_QUOTES);
            if ($emailToFileName != '' && file_exists("../templates/email/custom_override/{$emailToFileName}"))
            {
                unlink("../templates/email/custom_override/{$emailToFileName}");
            }
            $emailCcFileName = htmlentities($_REQUEST['emailCcFileName'], ENT_QUOTES);
            if ($emailCcFileName != '' && file_exists("../templates/email/custom_override/{$emailCcFileName}"))
            {
                unlink("../templates/email/custom_override/{$emailCcFileName}");
            }
        }
    }
}