<?php

include '../../LEAF_Request_Portal/db_mysql.php';
include '../../LEAF_Request_Portal/db_config.php';

class Session implements SessionHandlerInterface
{
    public function __construct()
    {
      $config = new Config();
      $db_phonebook = new DB($config->phonedbHost, $config->phonedbUser, $config->phonedbPass, $config->phonedbName);
      $this->db = $db_phonebook;
    }

    public function close()
    {
        return true;
    }

    public function destroy($sessionID)
    {
        $vars = array(':sessionID' => $sessionID);
        $this->db->prepared_query('DELETE FROM sessions
                                            WHERE sessionKey=:sessionID', $vars);
        return true;
    }

    public function gc($maxLifetime)
    {
        $vars = array(':time' => time() - $maxLifetime);
        $this->db->prepared_query('DELETE FROM sessions
                                            WHERE lastModified < :time', $vars);
        return true;
    }

    public function open($savePath, $sessionID)
    {
        return true;
    }

    public function read($sessionID)
    {
        $vars = array(':sessionID' => $sessionID);
        $res = $this->db->prepared_query('SELECT * FROM sessions
                                            WHERE sessionKey=:sessionID', $vars);

        return isset($res[0]['data']) ? $res[0]['data'] : '';
    }

    public function write($sessionID, $data)
    {
        $vars = array(':sessionID' => $sessionID,
                      ':data' => $data,
                      ':time' => time());
        $this->db->prepared_query('INSERT INTO sessions (sessionKey, data, lastModified)
                                            VALUES (:sessionID, :data, :time)
                                            ON DUPLICATE KEY UPDATE data=:data, lastModified=:time', $vars);
        return true;
    }

    public function getSessionData($sessionID)
    {
        $sessionData = $this->read($sessionID);
        return $this->unserialize_session_data($sessionData);
    }

    private function unserialize_session_data( $serialized_string )
  {
      $variables = array();
      $a = preg_split( "/(\w+)\|/", $serialized_string, -1, PREG_SPLIT_NO_EMPTY | PREG_SPLIT_DELIM_CAPTURE );

      for( $i = 0; $i<count($a); $i = $i+2 )
      {
          if(isset($a[$i+1]))
          {
            $variables[$a[$i]] = unserialize( $a[$i+1] );
          }
      }
      return( $variables );
  }
}
