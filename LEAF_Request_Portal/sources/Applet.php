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

class Applet
{
    public $siteRoot = '';
    private $db;

    private $login;

    private $dataActionLogger;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = new DataActionLogger($db, $login);
    }

    public function getReportTemplateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = scandir('../templates/reports/');
        $out = array();
        foreach ($list as $item)
        {
            if (preg_match('/.tpl$/', $item))
            {
                $out[] = $item;
            }
        }

        return $out;
    }

    public function getReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in)
        {
            return 0;
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        $data = array();
        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/reports/{$template}"))
            {
                $data['file'] = file_get_contents("../templates/reports/{$template}");
            }
        }

        return $data;
    }

    public function getHistoryReportTemplateList()
    {
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $list = scandir('../templates/reports/');
        $sub = array_map(function ($item) {
            return substr($item, 3);
        }, $list);
        $out = array();
        foreach ($sub as $item) {
            if (preg_match('/\.tpl$/', $item)) {
                array_push($out, $item);
            }
        }

        return $out;
    }

    public function getHistoryReportTemplate($templateFile)
    {
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

    public function getCompareHistoryReportTemplate($templateFile)
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

    public function newReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
            || $template == 'example'
            || $template == ''
            || preg_match('/^LEAF_/i', $template) === 1)
        {
            return 'Invalid or reserved name.';
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) === false)
        {
            $this->dataActionLogger->logAction(
                DataActions::CREATE,
                LoggableTypes::TEMPLATE_REPORTS_BODY,
                [new LogItem("template_reports_editor", "body", $template, $template)]
            );
            file_put_contents("../templates/reports/{$template}", '');
        }
        else
        {
            return 'File already exists';
        }

        return 'CreateOK';
    }

    private function isReservedFilename($file)
    {
        if($file == 'example'
            || substr($file, 0, 5) == 'LEAF_'
        ) {
            return true;
        }
        return false;
    }

    public function setReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
            || $this->isReservedFilename($template))
        {
            return 'Reserved filenames: LEAF_*, example';
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) !== false)
        {
            file_put_contents("../templates/reports/{$template}", $_POST['file']);
            $this->dataActionLogger->logAction(
                DataActions::MODIFY,
                LoggableTypes::TEMPLATE_REPORTS_BODY,
                [new LogItem("template_reports_editor", "body", $template, $template)]
            );
        }
    }

    public function removeReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in
            || $this->isReservedFilename($template))
        {
            return 0;
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) !== false)
        {
            $this->dataActionLogger->logAction(
                DataActions::DELETE,
                LoggableTypes::TEMPLATE_REPORTS_BODY,
                [new LogItem("template_reports_editor", "body", $template, $template)]
            );
            if (file_exists("../templates/reports/{$template}"))
            {
                return unlink("../templates/reports/{$template}");
            }
        }
    }

    public function removeHistoryReportTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if ($template != $in || $this->isReservedFilename($template)) {
            return 0;
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $list = scandir('../templates_history/leaf_programmer/');
        foreach ($list as $item) {
            if (substr($item, -strlen($template)) == $template) {
                unlink("../templates_history/leaf_programmer/{$item}");
            }
        }
        $vars = array(':template' => $in);
        $sql = "DELETE FROM template_history_files WHERE file_parent_name = :template";
        return $this->db->prepared_query($sql, $vars);
    }


    public function getHistory()
    {
        $history = [];

        $fields = [
            'message' => LoggableTypes::TEMPLATE_REPORTS_BODY
        ];
        foreach ($fields as $field => $type) {
            $fieldHistory = $this->dataActionLogger->getHistory(NULL, $field, $type);
            $history = array_merge($history, $fieldHistory);
        }

        usort($history, function($a, $b) {
            return $a['timestamp'] <=> $b['timestamp'];
        });

        return $history;
    }


    function setReportTemplateFileHistory($templateFileHistory)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $templateFileHistory);
        if (
            $template != $templateFileHistory
            || $this->isReservedFilename($template)
        ) {
            return 'Reserved filenames: LEAF_*, example';
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }

        $list = $this->getReportTemplateList();
        $time = date("Y-m-d h:i:s");

        $templateID = time();

        if (array_search($template, $list) !== false) {
            $fileData = $_POST['file'];
            $fileName = $templateID . "_" . $template;
            $filePath = "../templates_history/leaf_programmer/{$fileName}";
            file_put_contents($filePath, $fileData);

            $fileSize = filesize($filePath);

            $this->dataActionLogger->logTemplateFileHistory($fileName, $templateFileHistory, $filePath, $fileSize, $time);
        }
    }

    public function setReportMergeTemplate($in)
    {
        $template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
        if (
            $template != $in
            || $this->isReservedFilename($template)
        ) {
            return 'Reserved filenames: LEAF_*, example';
        }
        $template .= '.tpl';
        if (!$this->login->checkGroup(1)) {
            return 'Admin access required';
        }
        $list = $this->getReportTemplateList();

        if (array_search($template, $list) !== false) {
            file_put_contents("../templates/reports/{$template}", $_POST['file']);
            $this->dataActionLogger->logAction(
                DataActions::MERGE,
                LoggableTypes::TEMPLATE_REPORTS_BODY,
                [new LogItem("template_reports_editor", "body", $template, $template)]
            );
        }
    }
}
