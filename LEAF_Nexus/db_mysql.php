<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Generic database access for MySQL databases
    Date: September 4, 2007

 */

class DB
{
    private $db;                        // The database object

    private $dbHost;

    private $dbName;

    private $dbUser;

    private $log = array('<span style="color: red">Debug Log is ON</span>');    // error log for debugging

    private $debug = false;             // Are we debugging?

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
            $this->db = new PDO(
                "mysql:host={$this->dbHost};dbname={$this->dbName};charset=UTF8",
                $this->dbUser,
                $pass,
                array()
            );
        }
        catch (PDOException $e)
        {
            trigger_error('DB conn: ' . $e->getMessage());
            if(!$abortOnError) {
                echo '<div style="background-color: white; line-height: 200%; position: absolute; top: 50%; height: 200px; width: 750px; margin-top: -100px; left: 20%; font-size: 200%"><img src="../libs/dynicons/?img=edit-clear.svg&w=96" alt="Server Maintenance" style="float: left" /> Database connection error.<br />Please try again in 15 minutes.</div>';
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
            $query->execute($vars);
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
}
