<?php
/*
  * As a work of the United States government, this project is in the public domain within the United States.
  */

/*
  *  Template Handler
  */

namespace Portal;

use App\Leaf\Logger\DataActionLogger;
use App\Leaf\Logger\Formatters\DataActions;
use App\Leaf\Logger\Formatters\LoggableTypes;
use App\Leaf\Logger\LogItem;

/**
 * Summary of TemplateFileHistory
 */
class TemplateFileHistory
{
    public $siteRoot = '';
    private $db;

    private $login;

    private $dataActionLogger;

    /**
     * Summary of __construct
     * @param mixed $db
     * @param mixed $login
     */
    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new DataActionLogger($db, $login);
    }
    /**
     * Summary of getTemplateList
     * @return array|string
     */
    public function getTemplateList(): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }

        $list = scandir('../templates/');
        $out = [];

        foreach ($list as $item) {
            if (preg_match('/.tpl$/', $item)) {
                $out[] = $item;
            }
        }

        return $out;
    }


    /**
     * Summary of getTemplateHistoryList
     * @return array|string
     */
    public function getTemplateHistoryList(): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }

        $list = @scandir('../templates_history/template_editor/');
        if ($list === false) {
            return ['error' => 'Unable to read template history directory'];
        }

        $out = [];

        foreach ($list as $item) {
            if (preg_match('/.tpl$/', $item)) {
                $out[] = $item;
            }
        }

        return $out;
    }


    /**
     * Summary of getEmailTemplateHistoryList
     * @return array|string
     */
    public function getEmailTemplateHistoryList(): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }
        $out = array();
        $emailList = $this->db->query(
            'SELECT label, emailTo, emailCc, subject, body from email_templates'
        );
        foreach ($emailList as $listItem) {
            $data = array(
                'displayName' => $listItem['label'],
                'bodyFileName' => $listItem['body'],
                'emailToFileName' => $listItem['emailTo'],
                'emailCcFileName' => $listItem['emailCc'],
                'subjectFileName' => $listItem['subject']
            );
            $out[] = $data;
        }
        return $out;
    }



    /**
     * Summary of getComparedTemplateHistoryFile
     * @param mixed $templateFile
     * @return mixed
     */
    public function getComparedTemplateHistoryFile(string $templateFile): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }

        $vars = [
            ':templateFile' => $templateFile,
        ];

        $sql = 'SELECT file_parent_name, file_name, file_path
                  FROM `template_history_files`
                  WHERE file_name = :templateFile
                  ORDER BY `file_created` DESC';

        return $this->db->prepared_query($sql, $vars);
    }


    /**
     * Summary of getTemplateFileHistory
     * @param mixed $templateFile
     * @return mixed
     */
    public function getTemplateFileHistory(string $templateFile): array
    {
        if (!$this->login->checkGroup(1)) {
            return ['error' => 'Admin access required'];
        }

        $vars = [
            ':template_file' => $templateFile,
        ];

        $sql = 'SELECT file_id, file_parent_name, file_name, file_path, file_size, file_modify_by, file_created
                  FROM `template_history_files`
                  WHERE file_parent_name = :template_file
                  ORDER BY `file_id` DESC';

        return $this->db->prepared_query($sql, $vars);
    }

    /**
     * Summary of setTemplateFileHistory
     * @param mixed $templateFileHistory
     * @return string
     */
    public function setTemplateFileHistory(string $templateFileHistory): void
    {
        if (!$this->login->checkGroup(1)) {
            return;
        }

        $list = $this->getTemplateList();
        $time = date("Y-m-d h:i:s");
        $templateID = time();


        if (array_search($templateFileHistory, $list) !== false) {
            $fileData = $_POST['file'];
            $fileName = $templateID . "_" . $templateFileHistory;
            $filePath = "../templates_history/template_editor/{$fileName}";
            file_put_contents($filePath, $fileData);

            $fileSize = filesize($filePath);

            $this->dataActionLogger->logTemplateFileHistory(
                $fileName,
                $templateFileHistory,
                $filePath,
                $fileSize,
                $time
            );
        }
    }


    /**
     * Summary of setMergeTemplate
     * @param mixed $template
     * @return string
     */
    public function setMergeTemplate(string $template): ?string
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        $list = $this->getTemplateList();

        if (in_array($template, $list)) {
            file_put_contents("../templates/custom_override/{$template}", $_POST['file']);

            $this->dataActionLogger->logAction(
                DataActions::MERGE,
                LoggableTypes::TEMPLATE_BODY,
                [new LogItem("template_editor", "body", $template, $template)]
            );
        }

        return null;
    }

    public function setEmailMergeTemplate(string $template): ?string
    {

        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        $email_templates = $this->getEmailTemplateHistoryList();
        $body_list = array();
        foreach($email_templates as $rec) {
            $body_list[] = $rec['bodyFileName'];
        }
        if (in_array($template, $body_list)) {
            file_put_contents("../templates/email/custom_override/{$template}", $_POST['file']);

            $this->dataActionLogger->logAction(
                DataActions::MERGE,
                LoggableTypes::EMAIL_TEMPLATE_BODY,
                [new LogItem("email_template_body", "body", $template, $template)]
            );
        }

        return null;
    }
}