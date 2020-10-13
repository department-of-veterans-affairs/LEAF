<?php

require_once dirname(__FILE__) . '/../../vendor/autoload.php';

use Enqueue\Sqs\SqsConnectionFactory;

class EmailConsumer
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


    function processQueue()
    {
        $emailQueue = $this->context->createQueue('EmailQueue');
        $consumer = $this->context->createConsumer($emailQueue);
        $consumer->setMaxNumberOfMessages(10);
        $message = $consumer->receiveMessage(5000);
        $emailMessage = $message->getBody();
        $email = unserialize($emailMessage);

        if (mail($email['recipient'], $email['subject'], $email['body'], $email['headers']) )
        {
            $consumer->acknowledge($message);
        }
        else {
            $consumer->reject($message, true);
        }
    }
}