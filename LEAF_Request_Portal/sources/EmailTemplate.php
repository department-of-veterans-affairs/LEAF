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
}