<?php

require_once dirname(__FILE__) . '/../../libs/vendor/autoload.php';

use Enqueue\Dbal\DbalConnectionFactory;

class EmailProducer
{

    private $factory;

    private $context;

    public function __construct()
    {
        $this->initLeafQueueDB();
    }

    function initLeafQueueDB()
    {
        include_once 'QueueConfig.php';

        $queueConfig = new QueueConfig;

        $config = [
            'connection' => [
                'url' => "mysql://{$queueConfig->dbUser}:{$queueConfig->dbPass}@{$queueConfig->dbHost}:3306/{$queueConfig->dbName}",
                'driver' => "{$queueConfig->dbDriver}",
            ],
        ];

        $this->factory = new DbalConnectionFactory($config);
        $this->context = $this->factory->createContext();
        $this->context->createDataBaseTable();
    }

    public function sendToQueue($emailMessage)
    {
        $emailQueue = $this->context->createQueue('EmailQueue');
        $queueMessage = $this->context->createMessage($emailMessage);
        $producer = $this->context->createProducer();
        $producer->send($emailQueue, $queueMessage);
    }
}