<?php

require_once __DIR__.'/../vendor/autoload.php';

use GO\Scheduler;

$scheduler = new Scheduler();

$scheduler->call(function () {
    require_once dirname(__FILE__) . '/enqueue/EmailConsumer.php';

    $emailConsumer = new EmailConsumer();
    $emailConsumer->processQueue();

    return true;
})->everyMinute();

$scheduler.run();