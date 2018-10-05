<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

if (php_sapi_name() == 'cli')
{
    define('BR', "\r\n");
}
else
{
    define('BR', '<br />');
}

function rglob($pattern, $flags = 0)
{
    $files = glob($pattern, $flags);
    foreach (glob(dirname($pattern) . '/*', GLOB_ONLYDIR | GLOB_NOSORT) as $dir)
    {
        $files = array_merge($files, rglob($dir . '/' . basename($pattern), $flags));
        if (count($files) == 1)
        {
            return $files;
        }
    }

    return $files;
}

$nexusConfig = rglob('config.php');
$requestConfig = rglob('db_config.php');

$pattern = '/leafSecure/';
$existsInNexus = preg_grep($pattern, file($nexusConfig[0]));
$existsInRequest = preg_grep($pattern, file($requestConfig[0]));

echo 'Adding values to config files' . BR;
if (count($existsInNexus) === 0)
{
    $search = '$dbPass';
    $leafSecure = "\n    public static \$leafSecure = false;";
    $line_number = false;

    if ($handle = fopen($nexusConfig[0], 'r'))
    {
        $count = 0;
        while (($line = fgets($handle, 4096)) !== false and !$line_number)
        {
            $count++;
            $line_number = (strpos($line, $search) !== false) ? $count : $line_number;
        }
        fclose($handle);
    }

    $file = file($nexusConfig[0], FILE_IGNORE_NEW_LINES);   // read file into array
    $line = $file[$line_number];   // read line
    array_splice($file, $line_number, 0, $leafSecure);    // insert leafSecure setting at line number
    file_put_contents($nexusConfig[0], join("\n", $file));    // write to file
    echo 'Added to ' . $nexusConfig[0] . BR;
}
else
{
    echo 'Variable already exists in ' . $nexusConfig[0] . BR;
}

if (count($existsInRequest) === 0)
{
    $search = '$phonedbPass';
    $leafSecure = "\n    public static \$leafSecure = false;";
    $line_number = false;

    if ($handle = fopen($requestConfig[0], 'r'))
    {
        $count = 0;
        while (($line = fgets($handle, 4096)) !== false and !$line_number)
        {
            $count++;
            $line_number = (strpos($line, $search) !== false) ? $count : $line_number;
        }
        fclose($handle);
    }

    $file = file($requestConfig[0], FILE_IGNORE_NEW_LINES);   // read file into array
    $line = $file[$line_number];   // read line
    array_splice($file, $line_number, 0, $leafSecure);    // insert leafSecure setting at line number
    file_put_contents($requestConfig[0], join("\n", $file));    // write to file
    echo 'Added to ' . $requestConfig[0] . BR;
}
else
{
    echo 'Variable already exists in ' . $requestConfig[0] . BR;
}

echo 'Done' . BR;
