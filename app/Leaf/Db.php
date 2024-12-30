<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Generic database access for MySQL databases
    Date: September 4, 2007

 */

namespace App\Leaf;

class Db
{
    private $db;                        // The database object

    private $dbHost;

    private $dbName;

    private $dbUser;

    public $log = array('<span style="color: red">Debug Log is ON</span>');    // error log for debugging

    private $debug = false;             // Are we debugging?

    public $runErrors = false;

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

        try {
            $pdo_options = [
                // Error reporting mode of PDO. Can take one of the following values:
                // PDO::ERRMODE_SILENT, PDO::ERRMODE_WARNING, PDO::ERRMODE_EXCEPTION
                \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION
            ];

            $this->db = new \PDO(
                "mysql:host={$this->dbHost};dbname={$this->dbName};charset=UTF8",
                $this->dbUser,
                $pass,
                $pdo_options
            );

            // make sure there are no active transactions on script termination
            register_shutdown_function(function() {
                if($this->db->inTransaction()) {
                    $this->db->rollBack();
                }
            });
        } catch (\PDOException $e) {
            error_log('DB conn: ' . $e->getMessage());

            if (!$abortOnError) {
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
        if ($this->debug) {
            echo '<pre>';
            print_r($this->log);
            echo 'Duplicate queries:<hr />';

            $dupes = array();

            foreach ($this->log as $entry) {
                if (isset($entry['sql'])) {
                    $dupes[serialize($entry)]['sql'] = $entry['sql'];
                    $dupes[serialize($entry)]['vars'] = $entry['vars'];
                    $dupes[serialize($entry)]['counter'] = isset($dupes[serialize($entry)]['counter']) ? $dupes[serialize($entry)]['counter'] + 1 : 1;
                }
            }

            foreach ($dupes as $dupe) {
                if ($dupe['counter'] > 1) {
                    print_r($dupe);
                }
            }

            echo '<hr />';
            echo "</pre><br />Time: {$this->time} sec<br />";
        }

        try {
            $this->db = null;
        } catch (\Exception $e) {
            $this->logError('Connection normal closed: '.$e);
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
        if ($this->db->inTransaction()) {
            error_log(print_r($this->db, true));
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
                $this->log[] = $query->fetchAll(\PDO::FETCH_ASSOC);
            }
        }

        $res = $this->db->query($sql);
        if ($res !== false)
        {
            return $res->fetchAll(\PDO::FETCH_ASSOC);
        }
        $err = $this->db->errorInfo();
        $this->logError($err[2]);

        if ($this->debug)
        {
            $this->time += microtime(true) - $time1;
        }
    }

    public function errorInfo()
    {
        return $this->db->errorInfo();
    }

    /**
     * Allows data to be inserted and updated in batches
     * @param string $database
     * @param array $batchData
     * @param array $onDuplicateKeyUpdate
     * @return bool
     * Created at: 9/8/2022, 12:28:30 PM (America/Chicago)
     */
    public function insert_batch(string $database = '', array $batchData = [], array $onDuplicateKeyUpdate = []): bool
    {
        if (empty($database) || empty($batchData)) {
            return FALSE;
        }

        $insert_batch_sql = "INSERT into `$database`";

        // get the columns we are going to be inserting
        $firstBatchData = current($batchData);
        $firstBatchKeys = array_keys($firstBatchData);
        $insert_batch_sql .= " (`" . implode('`,`', $firstBatchKeys) . "`) VALUES ";

        // add in our values
        foreach ($batchData as $data) {

            $insert_batch_sql .= "(" . implode(",", array_fill(1, count($firstBatchKeys), '?')) . "),";
        }
        // remove the trailing , eh;
        $insert_batch_sql = trim($insert_batch_sql, ',');

        if (!empty($onDuplicateKeyUpdate)) {
            $insert_batch_sql .= " ON DUPLICATE KEY UPDATE";
            foreach ($onDuplicateKeyUpdate as $keys) {
                $insert_batch_sql .= " `$keys` = VALUES(`$keys`),";
            }
        }
        // remove the trailing , eh;
        $insert_batch_sql = trim($insert_batch_sql, ',');

        // now run the query.
        $statement = $this->db->prepare($insert_batch_sql);

        // using a loop since large datasets seem to be slower than a loop
        $executeData = [];
        foreach($batchData as $row){
            foreach($row as $datum) {
                $executeData[] = $datum;
            }
        }

        $statement->execute($executeData);
        return TRUE;
    }

    public function prepared_query($sql, $vars, $dry_run = false): array
    {
        if ($this->limit != '') {
            $sql = "{$sql} {$this->limit}";
            $this->limit = '';
        }

        $query = null;

        $time1 = microtime(true);

        if ($this->debug) {
            $q['sql'] = $sql;
            $q['vars'] = $vars;
            $this->log[] = $q;

            if ($this->debug >= 2) {
                $query = $this->db->prepare('EXPLAIN ' . $sql);
                $query->execute($vars);
                $this->log[] = $query->fetchAll(\PDO::FETCH_ASSOC);
            }
        }

        if ($dry_run == false && $this->dryRun == false) {
            $query = $this->db->prepare($sql);

            try {
                $query->execute($vars);
            } catch (\PDOException $e) {
                if ($this->runErrors)
                {
                    $this->show_data(["sql"=>$sql,"exception"=>$e]);
                }
            }
        } else {
            $this->log[] = 'Dry run: query not executed';
        }

        if ($this->debug) {
            $this->time += microtime(true) - $time1;
        }

        return $query->fetchAll(\PDO::FETCH_ASSOC);
    }

    public function pdo_select_query($sql, $vars): array
    {
        if ($this->limit != '') {
            $sql = "{$sql} {$this->limit}";
            $this->limit = '';
        }

        $query = null;

        $query = $this->db->prepare($sql);

        try {
            if ($query->execute($vars)) {
                $return_value = array (
                    'status' => array (
                        'code' => 2,
                        'message' => ''
                    ),
                    'data' => $query->fetchAll(\PDO::FETCH_ASSOC)
                );
            } else {
                $return_value = array (
                    'status' => array (
                        'code' => 4,
                        'message' => 'Query failed to execute'
                    )
                );
            }
        } catch (\PDOException $e) {
            $return_value = array (
                'status' => array (
                    'code' => 4,
                    'message' => 'PDO exception error'
                )
            );
            error_log(print_r($e, true));
        }

        return $return_value;
    }

    public function pdo_insert_query($sql, $vars): array
    {
        if ($this->limit != '') {
            $sql = "{$sql} {$this->limit}";
            $this->limit = '';
        }

        $query = null;

        $query = $this->db->prepare($sql);

        try {
            if ($query->execute($vars)) {
                $return_value = array (
                    'status' => array (
                        'code' => 2,
                        'message' => 'Insert was successful'
                    )
                );
            } else {
                $return_value = array (
                    'status' => array (
                        'code' => 4,
                        'message' => 'Query failed to execute'
                    )
                );
            }
        } catch (\PDOException $e) {
            $return_value = array (
                'status' => array (
                    'code' => 4,
                    'message' => 'PDO exception error'
                )
            );
            error_log(print_r($e, true));
        }

        return $return_value;
    }

    public function pdo_update_query($sql, $vars): array
    {
        if ($this->limit != '') {
            $sql = "{$sql} {$this->limit}";
            $this->limit = '';
        }

        $query = null;

        $query = $this->db->prepare($sql);

        try {
            if ($query->execute($vars)) {
                $return_value = array (
                    'status' => array (
                        'code' => 2,
                        'message' => 'Update was successful'
                    )
                );
            } else {
                $return_value = array (
                    'status' => array (
                        'code' => 4,
                        'message' => 'Query failed to execute'
                    )
                );
            }
        } catch (\PDOException $e) {
            $return_value = array (
                'status' => array (
                    'code' => 4,
                    'message' => 'PDO exception error'
                )
            );
            error_log(print_r($e, true));
        }

        return $return_value;
    }

    public function pdo_delete_query($sql, $vars): array
    {
        if ($this->limit != '') {
            $sql = "{$sql} {$this->limit}";
            $this->limit = '';
        }

        $query = null;

        $query = $this->db->prepare($sql);

        try {
            if ($query->execute($vars)) {
                $return_value = array (
                    'status' => array (
                        'code' => 2,
                        'message' => 'Delete was successful'
                    )
                );
            } else {
                $return_value = array (
                    'status' => array (
                        'code' => 4,
                        'message' => 'Query failed to execute'
                    )
                );
            }
        } catch (\PDOException $e) {
            $return_value = array (
                'status' => array (
                    'code' => 4,
                    'message' => 'PDO exception error'
                )
            );
            error_log(print_r($e, true));
        }

        return $return_value;
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
