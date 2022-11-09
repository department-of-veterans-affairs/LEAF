<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    db_mysql is a convienience layer
    Date Created: September 4, 2007
 */

class DB
{
    private $db;                        // The database object

    private $dbHost;

    private $dbName;

    private $dbUser;

    private $log = array('<span style="color: red">Debug Log is ON</span>');    // error log for debugging

    private $debug = false;             // Are we debugging?

    private $runErrors = false;         // On run errors specific error details

    private $time = 0;

    private $dryRun = false;            // only applies to prepared queries

    private $limit = '';

    private $isConnected = false;

    // Connect to the database
    public function __construct($host, $user, $pass, $database, $abortOnError = false)
    {
        $this->dbHost = $host;
        $this->dbUser = $user;
        $this->dbName = $database;

        $this->isConnected = true;
        try
        {

            $pdo_options = [
                // Error reporting mode of PDO. Can take one of the following values:
                // PDO::ERRMODE_SILENT, PDO::ERRMODE_WARNING, PDO::ERRMODE_EXCEPTION
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
            ];

            $this->db = new PDO(
                "mysql:host={$this->dbHost};dbname={$this->dbName};charset=UTF8",
                $this->dbUser,
                $pass,
                $pdo_options
            );
        }
        catch (PDOException $e)
        {
            trigger_error('DB conn: ' . $e->getMessage());
            if(!$abortOnError) {
                echo '<script>var min=5,max=10,timeWait=Math.ceil(Math.random()*(max-min))+min;function tryAgain(){timeWait--;let t=document.querySelector("#tryAgain");t.innerHTML="Loading in "+timeWait+" seconds...",t.style.pointerEvents="none",setTimeout(function(){timeWait>1?tryAgain():location.reload()},1e3)}</script>';
                echo '<div style="background-color: white; font-family: \'Source Sans Pro\', helvetica;line-height: 200%; position: absolute; top: 50%; height: 200px; width: 750px; margin-top: -100px; left: 20%; font-size: 200%">⛈️ We are experiencing heavy database traffic<p style="margin-left: 54px">Please come back at your next convenience</p><button id="tryAgain" onclick="tryAgain()" style="font-size: 14pt; padding: 8px; margin-left: 54px">Try again now</button></div>';
                echo '<!-- Database Error: ' . $e->getMessage() . ' -->';
                http_response_code(503);
                exit();
            }
            $this->isConnected = false;
        }

        unset($pass);
    }

    public function __destruct()
    {
        try {
            $this->db = null;
        } catch (Exception $e) {
            $this->logError('Connection normal closed: '.$e);
        }

        if ($this->debug)
        {
            echo '<pre>';
            print_r($this->log);
            echo 'Duplicate queries:<hr />';
            $dupes = array();
            foreach ($this->log as $entry)
            {
                if (isset($entry['sql']))
                {
                    $dupes[serialize($entry)]['sql'] = $entry['sql'];
                    $dupes[serialize($entry)]['vars'] = $entry['vars'];
                    $dupes[serialize($entry)]['counter'] = isset($dupes[serialize($entry)]['counter']) ? $dupes[serialize($entry)]['counter'] + 1 : 1;
                }
            }
            foreach ($dupes as $dupe)
            {
                if ($dupe['counter'] > 1)
                {
                    print_r($dupe);
                }
            }
            echo '<hr />';
            echo "</pre><br />Time: {$this->time} sec<br />";
        }
    }

    // Log errors from the database
    public function logError($error)
    {
        $this->log[] = $error;
    }

    public function beginTransaction()
    {
        if ($this->debug)
        {
            $this->log[] = 'Beginning Transaction';
        }

        return $this->db->beginTransaction();
    }

    public function commitTransaction()
    {
        if ($this->debug)
        {
            $this->log[] = 'Committing Transaction';
        }

        return $this->db->commit();
    }

    /**
     * Limits number of results.
     * The limit is cleared before each query, and must be reset if needed
     * @param int $offset
     * @param int $quantity
     */
    public function limit($offset, $quantity = 0)
    {
        $offset = (int)$offset;
        $quantity = (int)$quantity;

        if ($quantity > 0)
        {
            $this->limit = "LIMIT {$offset},{$quantity}";
        }
    }

    // Raw Queries the database and returns an associative array
    public function query($sql)
    {
        if ($this->limit != '')
        {
            $sql = "{$sql} {$this->limit}";
            $this->limit = '';
        }

        $time1 = microtime(true);
        if ($this->debug)
        {
            $this->log[] = $sql;
            if ($this->debug >= 2)
            {
                $query = $this->db->query('EXPLAIN ' . $sql);
                $this->log[] = $query->fetchAll(PDO::FETCH_ASSOC);
            }
        }

        $res = $this->db->query($sql);
        if ($res !== false)
        {
            return $res->fetchAll(PDO::FETCH_ASSOC);
        }
        $err = $this->db->errorInfo();
        $this->logError($err[2]);

        if ($this->debug)
        {
            $this->time += microtime(true) - $time1;
        }
    }

    public function prepared_query($sql, $vars, $dry_run = false)
    {
        if ($this->limit != '')
        {
            $sql = "{$sql} {$this->limit}";
            $this->limit = '';
        }

        $query = null;

        $time1 = microtime(true);
        if ($this->debug)
        {
            $q['sql'] = $sql;
            $q['vars'] = $vars;
            $this->log[] = $q;
            if ($this->debug >= 2)
            {
                $query = $this->db->prepare('EXPLAIN ' . $sql);
                $query->execute($vars);
                $this->log[] = $query->fetchAll(PDO::FETCH_ASSOC);
            }
        }

        if ($dry_run == false && $this->dryRun == false)
        {            
            $query = $this->db->prepare($sql);
            try {
                $query->execute($vars);
            } catch (PDOException $e) {
                if ($this->runErrors)
                {
                    $this->show_data(["sql"=>$sql,"exception"=>$e]);
                }
            }

        }
        else
        {
            $this->log[] = 'Dry run: query not executed';
        }

        if ($this->debug)
        {
            $this->time += microtime(true) - $time1;
        }

        return $query->fetchAll(PDO::FETCH_ASSOC);
    }

    private function show_data(array $dataIn = []) {
        echo "<pre>";
        echo "Host: " . $this->dbHost."\n";
        echo "User: " . $this->dbUser ."\n";
        echo "DB Name: " . $this->dbName."\n";
        print_r($dataIn);
        die("full stop");
    }

    /**
     * Query a key-value table structure
     * Returns an associative array
     * @param string $sql
     * @param string $key - Name of the column in the table
     * @param mixed $value - Name of the column in the table as a string, or list of columns in an array
     * @param array $vars - parameratized variables
     */
    public function query_kv($sql, $key, $value, $vars = array())
    {
        $out = array();
        $res = $this->prepared_query($sql, $vars);

        if (!is_array($value))
        {
            foreach ($res as $result)
            {
                $out[$result[$key]] = $result[$value];
            }
        }
        else
        {
            foreach ($res as $result)
            {
                foreach ($value as $column)
                {
                    $out[$result[$key]][$column] = $result[$column];
                }
            }
        }

        return $out;
    }

    // Translates the * wildcard to SQL % wildcard
    public function parseWildcard($query)
    {
        return str_replace('*', '%', $query . '*');
    }

    // Clean up all wildcards
    public function cleanWildcards($input)
    {
        $input = str_replace('%', '*', $input);
        $input = str_replace('?', '*', $input);
        $input = preg_replace('/\*+/i', '*', $input);
        $input = preg_replace('/(\s)+/i', ' ', $input);
        $input = preg_replace('/(\*\s\*)+/i', '', $input);

        return $input;
    }

    public function getLastInsertID()
    {
        return $this->db->lastInsertId();
    }

    public function isConnected()
    {
        return $this->isConnected;
    }

    public function disableDebug()
    {
        $this->debug = false;
    }

    public function enableDebug()
    {
        $this->debug = 1;
    }

    public function disableDryRun()
    {
        $this->dryRun = false;
    }

    public function enableDryRun()
    {
        $this->dryRun = true;
    }

    private function checkLastModified() {
        //get the last build time
        $defaultTime = "Thur, January 1, 1970 00:00:00 GMT";
        $lastBuildTime = getenv('LAST_BUILD_DATE', true) ? getenv('LAST_BUILD_DATE') : $defaultTime;

        // set last-modified header
        // header('Cache-Control: no-cache, must-revalidate');
        header('Last-Modified: ' . $lastBuildTime );

        // Check if last build time is exactly the same (if so, use cache)
        if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE'])) {
            if ($lastBuildTime === $_SERVER['HTTP_IF_MODIFIED_SINCE']) {
                http_response_code(304);
                header('X-MODIFIED-SINCE: MATCH');
                die();
            }
        }
        header('X-CONTENT-RETURN: YES');
    }
}
