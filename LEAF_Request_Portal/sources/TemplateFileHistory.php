<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
 *  Template Handler
 */

namespace Portal;


class TemplateFileHistory
{
    public $siteRoot = '';
    private $db;

    private $login;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new \Leaf\DataActionLogger($db, $login);
    }

    public function getTemplateList()
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $list = scandir('../templates/');
        $out = array();
        foreach ($list as $item) {
            if (preg_match('/.tpl$/', $item)) {
                $out[] = $item;
            }
        }

        return $out;
    }

    public function getTemplateHistoryList()
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        $list = scandir('../templates_history/template_editor/');
        $out = array();
        foreach ($list as $item) {
            if (preg_match('/.tpl$/', $item)) {
                $out[] = $item;
            }
        }

        return $out;
    }


    public function getComparedTemplateHistoryFile($templateFile)
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        $vars = array(
            ':templateFile' => $templateFile
        );

        $sql = 'SELECT file_parent_name, file_name, file_path
                FROM `template_history_files`
                WHERE file_name = :templateFile
                ORDER BY `file_created` DESC';

        return $this->db->prepared_query($sql, $vars);
    }


    public function getTemplateFileHistory($templateFile)
    {
        error_log(print_r($templateFile, true));
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $vars = array(
            ':template_file' => $templateFile
        );
        $sql = 'SELECT file_id, file_parent_name, file_name, file_path, file_size, file_modify_by, file_created
                FROM `template_history_files`
                WHERE file_parent_name = :template_file
                ORDER BY `file_created` DESC';


        return $this->db->prepared_query($sql, $vars);
    }

    function setTemplateFileHistory($templateFileHistory)
    {
        error_log(print_r($templateFileHistory, true));
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();
        $time = date("Y-m-d h:i:s");
        $random_number = rand(1, 100);

        // Generate a new random number if the previous one is already being used
        while (file_exists("../templates_history/template_editor/{$random_number}.'_'.{$templateFileHistory}")) {
            $random_number = rand(1, 100);
        }

        if (array_search($templateFileHistory, $list) !== false) {
            $fileData = $_POST['file'];
            $fileName = $random_number. "_" .$templateFileHistory;
            $filePath = "../templates_history/template_editor/{$fileName}";
            file_put_contents($filePath, $fileData);

            $fileSize = filesize($filePath);

            $this->dataActionLogger->logTemplateFileHistory($fileName, $templateFileHistory, $filePath, $fileSize, $time);
        }
    }

    public function setMergeTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        if (array_search($template, $list) !== false)
        {
            file_put_contents("../templates/custom_override/{$template}", $_POST['file']);

            $this->dataActionLogger->logAction(
                \Leaf\DataActions::MODIFY,
                \Leaf\LoggableTypes::TEMPLATE_BODY,
                [new \Leaf\LogItem("template_editor", "body", $template, $template)]
            );
        }
    }
}
