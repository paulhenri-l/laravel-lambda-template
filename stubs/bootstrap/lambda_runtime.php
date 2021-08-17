<?php


use Illuminate\Contracts\Console\Kernel as ConsoleKernelContract;
use Illuminate\Contracts\Foundation\Application;
use PaulhenriL\LaravelLambdaEngine\Helpers\SecretsLoader;
use PaulhenriL\LaravelLambdaEngine\Helpers\StorageDirectories;

/** @var $app Application */

// Add output constants.
if (!defined('STDIN')) define('STDIN', fopen('php://stdin', 'rb'));
if (!defined('STDOUT')) define('STDOUT', fopen('php://stdout', 'wb'));
if (!defined('STDERR')) define('STDERR', fopen('php://stderr', 'wb'));

// If we're not in lambda there's nothing to do.
if (!isset($_ENV['LAMBDA_TASK_ROOT'])) {
    return;
}

if ($app->configurationIsCached()) {
    return;
}

// Load secrets
SecretsLoader::addToEnvironment(json_decode($_ENV['PHL_SSM_SECRETS'], true));

// Create storage dirs
fwrite(STDERR, 'Creating storage directories' . PHP_EOL);
StorageDirectories::create();

// Use new storage dirs
$app->useStoragePath(StorageDirectories::PATH);

// Cache configuration.
fwrite(STDERR, 'Caching Laravel configuration' . PHP_EOL);
$app->make(ConsoleKernelContract::class)->call('config:cache');
