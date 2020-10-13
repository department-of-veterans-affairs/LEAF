<?php

require_once dirname(__FILE__) . '/../../vendor/autoload.php';

use Enqueue\Sqs\SqsConnectionFactory;

class EmailProducer
{

    private $factory;

    private $context;

    public function __construct()
    {
        $this->initAwsSQS();
    }

    function initAwsSQS()
    {
        include_once 'QueueConfig.php';

        $queueConfig = new QueueConfig;

        $awsClient = new Aws\Sqs\SqsClient([
            'credentials' => [
                'key' => $queueConfig->key,
                'secret' => $queueConfig->secret,
            ],
            'region' => $queueConfig->region,
            'version' => $queueConfig->version,
            'endpoint' => $queueConfig->endPoint
        ]);

        $this->factory = new SqsConnectionFactory($awsClient);
        $this->context = $this->factory->createContext();
    }

    public function sendToQueue($emailMessage)
    {
        $emailQueue = $this->context->createQueue('EmailQueue');
        $queueMessage = $this->context->createMessage($emailMessage);
        $producer = $this->context->createProducer();
        $producer->send($emailQueue, $queueMessage);
    }
}