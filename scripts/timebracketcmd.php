<?php
// force types (return 'asd' with bool will return true)
declare(strict_types=1);

/**
 * Hey Shane. Got a mini-project for you. I need a php script that when run checks the time and compares it to a time-bracket given via a set of variables. If it's within that time period, it executes an outside php or shell script (again from a variable) from a hard-coded directory. If not, it goes to sleep for a variable determined time and then checks again. Rinse and repeat.
 */
class TimeBracketCmd
{

    private int $sleepTime = 300;
    private int $startTime;
    private int $endTime;
    private string $runAtExactTime = '';
    private string $processToRun;
    private string $arguments = '';
    private bool $continue = TRUE;
    protected string $directoryToRunFrom = __DIR__.'/scheduled-task-commands/';
    protected int $time;

    /**
     * [Description for __construct]
     *
     * @param string $processToRun - JSON {name:'test.php',arguments:{}}
     * @throws Exception
     *
     * Created at: 6/22/2022, 8:52:43 AM (America/Chicago)
     */

    public function __construct(string $processToRun = '')
    {

        // set our time
        $this->time = time();

        $this->setProcessToRun($processToRun);

    }

 /**
     * Set the sleep time
     *
     * @param int $sleepTime - time in seconds to sleep minimum of 1 seconds please.
     * @throws Exception
     *
     * Created at: 6/22/2022, 8:43:59 AM (America/Chicago)
     */
    public function setSleepTime(int $sleepTime): void
    {
        if ($sleepTime < 1) {
            throw new Exception('Sleep Time must be more than 1 Second');
        } else {
            $this->sleepTime = $sleepTime;
        }
    }

    /**
     * @param string $runAtExactTime
     * @return void
     * @throws Exception
     *
     * Created at: 8/19/2022, 1:30:59 PM (America/Chicago)
     */
    public function setRunAtExactTime(string $runAtExactTime): void
    {

        // if the time is not greater than zero lets do something about it.
        if (!strtotime($runAtExactTime) > 0) {
            throw new Exception('This requested time resulted in an error.');
        } else {
            $this->runAtExactTime = $runAtExactTime;
            $this->sleepTime = 0;
        }
    }

    /**
     * Sets start time, should be a valid unix timestamp
     *
     * @param int $startTime - unix timestamp
     * @throws Exception
     *
     * Created at: 6/22/2022, 8:44:47 AM (America/Chicago)
     */
    public function setStartTime(int $startTime): void
    {
        if ($startTime < $this->time) {
            throw new Exception('Start Time must start after now!');
        } elseif (!empty($this->endTime) && $this->endTime < $startTime) {
            throw new Exception('Start Time must start before End Time');
        } else {
            $this->startTime = $startTime;
        }
    }

    /**
     * Sets end time, should be a valid unix timestamp
     *
     * @param int $endTime - unix timestamp
     * @throws Exception
     *
     * Created at: 6/22/2022, 8:45:15 AM (America/Chicago)
     */
    public function setEndTime(int $endTime): void
    {
        if ($endTime < $this->time) {
            throw new Exception('End Time must start after now!');
        } elseif (!empty($this->startTime) && $this->startTime > $endTime) {
            throw new Exception('End Time must must be after Start Time');
        } else {
            $this->endTime = $endTime;
        }
    }

    /**
     * Sets the command that will be run on the interval, it will continue until the requested end time
     *
     * @param mixed $processToRun - JSON {name:'test.php',arguments:{}}
     * @return void
     * @throws Exception
     *
     * Created at: 6/22/2022, 8:54:31 AM (America/Chicago)
     *
     * @todo: Need better check for php vs sh vs w/e script and that its a valid command
     */
    public function setProcessToRun(string $processToRun): void
    {

        $possibleJsonArray = json_decode($processToRun, true);

        // make sure the json came through okay
        if ((json_last_error() == JSON_ERROR_NONE)) {
            // pass our arguments off for when we go to send them to the script
            if (!empty($possibleJsonArray['arguments'])) {
                // assign it to a var so we can make the next check a bit easier to read.
                $arg = $possibleJsonArray['arguments'];
                // check if its an array or string, may want to add something to the set args to handle this better than encode and decode
                $arg = (is_array($arg) ? json_encode($arg) : $arg);
                $this->setArguments($arg);
            }
            // get things set for the next part of the story
            $processFileName = $possibleJsonArray['name'];

        } else {
            /// or this is just a process being passed in as a string...
            $processFileName = $processToRun;
        }

        // validate the process name
        if (empty($processFileName)) {
            throw new Exception('Process To Run is not valid');
        } elseif (stristr($processFileName, '.php') !== FALSE && stristr($processFileName, '.sh') !== FALSE) {
            throw new Exception('Only php or shell scripts can be run!');
        } elseif (is_file($this->directoryToRunFrom . $processFileName) === FALSE) {
            throw new Exception('This process was not found!');
        } else {
            $processFileName = str_replace(['../', './'], '', $processFileName);

            $this->processToRun = $processFileName;
        }
    }

    /**
     * Add arguments that are needed to be supplied to the command, can be string or json array
     * @param string $arguments
     * @return void
     *
     * Created at: 6/29/2022, 2:00:45 PM (America/Chicago)
     */
    public function setArguments(string $arguments): void
    {
        // since json strings and a regular string do not behave the same I have to do a couple different things
        // validate this is a json string
        json_decode($arguments);
        if ((json_last_error() == JSON_ERROR_NONE)) {
            $this->arguments = addslashes($arguments);
        } else {
            $this->arguments = $arguments;
        }
    }

    /**
     * Is this code ready to run?
     * @return bool
     *
     * Created at: 8/19/2022, 9:23:45 AM (America/Chicago)
     *
     */
    private function canIRun(): bool
    {
        // ie run at 7 am every day
        if (!empty($this->runAtExactTime)) {
            return TRUE;
        } // only run if we are within the set time frame, ie every 5 minutes between 5 am to 6 am
        elseif ($this->time > $this->startTime && $this->time < $this->endTime) {
            return TRUE;
        } // run only if we are on the exact time, we do not want to add complexity with start and end time

        return FALSE;
    }

    /**
     * This is for setting sleep, since we have two different ways to set our sleep this gives us a nice clean way
     * to set our sleep time
     * @return void
     */
    private function setSleep(): void
    {

        if (!empty($this->runAtExactTime)) {
            $exactRunTimestamp = strtotime($this->runAtExactTime);
            $currentTime = time();
            // get the time for tomorrow if we are passed the time.
            if ($currentTime > $exactRunTimestamp) {
                $exactRunTimestamp = strtotime($this->runAtExactTime . ' tomorrow');
            }

            if ($currentTime > $exactRunTimestamp) {
                throw new Exception('There was an issue with runAtExactTime and strtotime!');
            }

            // sleep the number of seconds until we need to run this
            $this->setSleepTime($exactRunTimestamp - $currentTime);

        }
        // the else would end up being the between time and no real to do any checks on that

        sleep($this->sleepTime);

    }

    /**
     * This is the main process for the timed run
     *
     * @return bool
     *
     * Created at: 6/23/2022, 11:28:30 AM (America/Chicago)
     */
    public function run(): bool
    {

        // useful data to help tell what script the output is for so we can write this to file if need be
        echo sprintf("Started at: %s \r\n", date('Y-m-d g:i:s a'));
        echo sprintf("Running command: %s \r\n", $this->processToRun);
        echo sprintf("Sleep is at: %d seconds \r\n", $this->sleepTime);
        echo "Command output: \r\n";

        while ($this->continue === TRUE) {

            $this->time = time();

            // since it will never hit the run portion right away for the between times, might as well do the sleep
            // first. this way we can make the run at 7 am portion more simple

            $this->setSleep();

            // are we within this time frame? run the command
            if ($this->canIRun()) {
                // determine php vs sh this could be done better I am sure.
                $phpsh = (stristr($this->processToRun, '.php')) ? 'php ' : 'bash ';

                // build our full process string
                //$process_w_dir = $phpsh . $this->directoryToRunFrom . $this->processToRun . ' ' . $this->arguments;
                $process_w_dir = sprintf('%s %s%s %s', $phpsh, $this->directoryToRunFrom, $this->processToRun, $this->arguments);
                // some commands may fail this way however this *should* take care of most things for now.
                //$process_w_dir = escapeshellcmd($process_w_dir); // this blows things up with json arrays

                // allows you to customize data going out, for example the 3rd argument you can output directly to a file.
                $descriptorspec = [STDIN, STDOUT, STDOUT];
                // example how to use files keeping for now just for note sake
                //$descriptorspec = [STDIN, array("file", "test-output.txt", "a"), array("file", "error-output.txt", "a")];
                $proc = proc_open($process_w_dir, $descriptorspec, $pipes);
                if (is_resource($proc)) {
                    $dat = proc_get_status($proc);
                    // information that should be put towards any logging, for now I am just dumping 
                    //var_dump($dat);
                    proc_close($proc);
                }

            } else {
                echo "Wait for next cycle! \r\n";
            }


            // if we are beyond the end time then lets close out of this
            if (!empty($this->endTime) && $this->time > $this->endTime) {
                $this->continue = FALSE;
            }

        }

        return TRUE;
    }


}