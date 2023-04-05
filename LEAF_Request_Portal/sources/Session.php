<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Login class and session handler
    Date Created: September 11, 2007

*/

namespace Portal;

class Session implements \SessionHandlerInterface
{
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
    }

    public function close(): bool
    {
        return true;
    }

    public function destroy($sessionID): bool
    {
        $vars = array(':sessionID' => $sessionID);
        $this->db->prepared_query('DELETE FROM sessions
                                            WHERE sessionKey=:sessionID', $vars);

        return true;
    }

    public function gc($maxLifetime): int|false
    {
        $vars = array(':time' => time() - $maxLifetime);
        $this->db->prepared_query('DELETE FROM sessions
                                            WHERE lastModified < :time', $vars);

        return true;
    }

    public function open($savePath, $sessionID): bool
    {
        return true;
    }

    public function read($sessionID): string|false
    {
        $vars = array(':sessionID' => $sessionID);
        $res = $this->db->prepared_query('SELECT * FROM sessions
                                            WHERE sessionKey=:sessionID', $vars);

        return isset($res[0]['data']) ? $res[0]['data'] : '';
    }

    public function write($sessionID, $data): bool
    {
        $vars = array(':sessionID' => $sessionID,
                      ':data' => $data,
                      ':time' => time(), );
        $this->db->prepared_query('INSERT INTO sessions (sessionKey, data, lastModified)
                                            VALUES (:sessionID, :data, :time)
                                            ON DUPLICATE KEY UPDATE data=:data, lastModified=:time', $vars);

        return true;
    }
}
