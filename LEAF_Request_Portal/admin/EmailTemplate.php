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

    public function getHistory($filterByName)
    {
        return $this->dataActionLogger->getHistory($filterByName, "body", \LoggableTypes::EMAIL_TEMPLATE);
    }
}