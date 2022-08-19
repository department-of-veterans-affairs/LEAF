<?php
/*
#Request


#todo
- set this up to work with unixtimestamps as well as human time
- validation to disallow ../ in command
- validate command is there

#How to run
php timebracketcmd.php '3:18pm 6/21/2022' '5:00pm 6/22/2022' 'touch timebracketcmdtest.txt' 30
- arg one is start time
- arg two is end time
- arg three is command without dir
- arg four is sleep time in seconds

#testing samples
-errors out due to bad time
php timebracketcmd.php '3:18pm 6/21/2022' '500pm 6/22/2022' 'touch timebracketcmdtest.txt' 30
*/
error_reporting(E_ALL);
ini_set('display_errors', 1);

// requires zts to be enabled and this installed.
//use \parallel\{Runtime, Future, Channel, Events};

require_once('timebracketcmd.php');
echo date('Y-m-d g:i:s a') . "\r\n";

//$program = function($start,$end,$process,$sleep=null){
//    $test = new TimeBracketCmd($start,$end,$process,$sleep);
//    $ret = $test->run();
//    var_dump($ret);
//};

try {

    // looking at way to run things concurrently since that would be the next step.
    //\parallel\run($program, [strtotime('1:43pm'), strtotime('10:00pm'), 'test.sh', 30]);
    //\parallel\run($program, [strtotime('1:43pm'), strtotime('10:00pm'), 'test.php', 30]);

    $processToRun = json_encode(['name' => 'test.php', 'arguments' => ['numberOfTimes' => 'infinite', 'filesToLookFor' => ['a.txt', 'b.txt', 'c.txt']]]);
    //$processToRun = json_encode(['name' => 'test.sh', 'arguments' => "-u 'moomilk and the cow factory'"]);
    $test = new TimeBracketCmd($processToRun);
    $test->setStartTime(strtotime('9:15pm'));
    $test->setEndTime(strtotime('10:00pm'));
    //$test = new TimeBracketCmd(strtotime('1:43pm'),strtotime('10:00pm'),'test.sh');
    //$test = new TimeBracketCmd(strtotime('3:00pm'),strtotime('9:00pm'),'test.php');
    //$test = new TimeBracketCmd(strtotime('3:05pm'));
    //$test->setSleepTime('');
    //$test->setStartTime('');
    //$test->setEndTime('');
    //$test->setProcessToRun('');
    $test->setSleepTime(30);
    //$test_json = json_encode(['color'=>'red','value'=>'#f00']);
    //$test->setArguments($test_json);
    //$test->setArguments("-u 'moomilk and the cow factory'");
    $ret = $test->run();
    var_dump($ret);
    //$test2 = new TimeBracketCmd(strtotime('1:43pm'),strtotime('10:00pm'),'test.php',100);
    //$ret2 = $test2->run();
    //var_dump($ret2);

    echo 'end';
} catch (Exception $e) {
    echo sprintf("Message: %s \r\nFile: %s \r\nLine: %s \r\nTrace: %s\r\n", $e->getMessage(), $e->getFile(), $e->getLine(), $e->getTraceAsString());
}
