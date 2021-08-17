<?php

use Illuminate\Foundation\Application;
use PaulhenriL\LaravelLambdaEngine\Helpers\SqsQueueHandler;

require __DIR__ . '/vendor/autoload.php';

/** @var Application $app */
$app = require __DIR__ . '/bootstrap/app.php';

$kernel = $app->make(
    Illuminate\Contracts\Console\Kernel::class
);

$kernel->bootstrap();

return $app->makeWith(SqsQueueHandler::class, [
    'connection' => 'sqs', // this is the Laravel Queue connection
    'queue' => getenv('SQS_QUEUE'),
]);
