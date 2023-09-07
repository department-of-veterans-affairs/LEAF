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

class Template
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

    public function getTemplateList()
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = scandir('../templates/');
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

    /**
     * @return array
     *
     * Created at: 5/24/2023, 10:22:51 AM (America/New_York)
     */
    public function getCustomTemplateList(): array
    {
        if (!$this->login->checkGroup(1))
        {
            $return_value = array(
                'status' => array(
                    'code' => 4,
                    'message' => 'Admin access required'
                )
            );
        }
        $list = scandir('../templates/custom_override');
        $out = array();

        foreach ($list as $item) {
            if (preg_match('/.tpl$/', $item)) {
                $out['success'][] = $item;
            }
        }

        $return_value = array(
            'status' => array(
                'code' => 2,
                'message' => ''
            ),
            'data' => $out
        );

        return $return_value;
    }

    public function getTemplate($template, $getStandard = false)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        $data = array();
        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/custom_override/{$template}")
                  && !$getStandard)
            {
                $data['modified'] = 1;
                $data['file'] = file_get_contents("../templates/custom_override/{$template}");
            }
            else
            {
                $data['modified'] = 0;
                $data['file'] = file_get_contents("../templates/{$template}");
            }
        }

        return $data;
    }

    public function setTemplate($template)
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
                DataActions::MODIFY,
                LoggableTypes::TEMPLATE_BODY,
                [new LogItem("template_editor", "body", $template, $template)]
            );
        }
    }

    public function removeCustomTemplate($template)
    {
        if (!$this->login->checkGroup(1))
        {
            return 'Admin access required';
        }
        $list = $this->getTemplateList();

        if (array_search($template, $list) !== false)
        {
            if (file_exists("../templates/custom_override/{$template}"))
            {
                $this->dataActionLogger->logAction(
                    DataActions::RESTORE,
                    LoggableTypes::TEMPLATE_BODY,
                    [new LogItem("template_editor", "body", $template, $template)]
                );
                return unlink("../templates/custom_override/{$template}");
            }
        }
    }


    public function getHistory()
    {
        $history = [];

        $fields = [
            'message' => LoggableTypes::TEMPLATE_BODY
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
