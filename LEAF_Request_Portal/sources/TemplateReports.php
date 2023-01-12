<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
 *  Template Handler
 */

namespace Portal;

class TemplateReports
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
                \Leaf\DataActions::MODIFY,
                \Leaf\LoggableTypes::TEMPLATE_REPORTS_BODY,
                [new \Leaf\LogItem("template_reports_editor", "body", $template, $template)]
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
            if (file_exists("../templates/reports/{$template}"))
            {
                return unlink("../templates/reports/{$template}");
            }
        }
    }


    public function getHistory()
    {
        $history = [];

        $fields = [
            'message' => \Leaf\LoggableTypes::TEMPLATE_REPORTS_BODY
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
}