<?php

require_once dirname(__FILE__) . '/../../libs/vendor/autoload.php';

use Interop\Queue\Message;
use Interop\Queue\Consumer;
use Enqueue\Dbal\DbalConnectionFactory;

class EmailConsumer
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
    }


    function processQueue()
    {
        $emailQueue = $this->context->createQueue('EmailQueue');
        $consumer = $this->context->createConsumer($emailQueue);
        $subscriptionConsumer = $this->context->createSubscriptionConsumer();
        $subscriptionConsumer->subscribe($consumer, function(Message $message, Consumer $consumer) {

            $emailMessage = $message->getBody();
            $email = unserialize($emailMessage);
            if (mail($email['recipient'], $email['subject'], $email['body'], $email['headers']) )
            {
                $consumer->acknowledge($message);
            }
            else
            {
                $consumer->reject($message, true);
                return true;
            }
        });
        $subscriptionConsumer->consume(3000);
    }
}