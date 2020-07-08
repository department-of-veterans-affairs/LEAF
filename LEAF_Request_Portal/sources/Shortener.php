<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';

class Shortener
{
    public $siteRoot = '';

    private $db;

    private $login;

    private $charset = '23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz';
    private $offset = 10000000; // offset for minimum 5 character ID

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        // todo: replace with config based URL
        $this->siteRoot = "{$protocol}://" . HTTP_HOST . dirname($_SERVER['PHP_SELF']);
    }

    // Algo based in part on https://helloacm.com/base62/
    private function encodeShortUID($in)
    {
        $in += $this->offset;
        $r = $in % 56;
        $res = substr($this->charset, $r, 1);
        $q = floor($in / 56);

        while($q) {
            $r = $q % 56;
            $q = floor($q / 56);
            $res = substr($this->charset, $r, 1) . $res;
        }
        return $res;
    }

    private function decodeShortUID($in)
    {
        $lim = strlen($in);
        $res = 0;
        for($i = 0; $i < $lim; $i++) {
            $res = 56 * $res + strpos($this->charset, substr($in, $i, 1));
        }
        return $res - $this->offset;
    }

    public function getFormQuery($shortUID) {
        $shortID = $this->decodeShortUID($shortUID);
        $vars = array(':shortID' => $shortID);
        $resReport = $this->db->prepared_query('SELECT data FROM short_links
                                    WHERE shortID=:shortID', $vars);
        if(!isset($resReport[0])) {
            return '';
        }
        require_once dirname(__FILE__) . '/../form.php';
        $form = new Form($this->db, $this->login);
        return $form->query($resReport[0]['data']);
    }

    public function shortenFormQuery($data) {
        $hash = hash('sha256', $data);

        $vars = array(':hash' => $hash);
        $res = $this->db->prepared_query('SELECT shortID FROM short_links
                                            WHERE hash=:hash', $vars);
        if(count($res) > 0) {
            return $this->encodeShortUID($res[0]['shortID']);
        }

        $vars = array(':data' => $data,
                      ':hash' => $hash);
        $this->db->prepared_query('INSERT INTO short_links (type, hash, data)
                                    VALUES ("formQuery", :hash, :data)', $vars);
        return $this->encodeShortUID($this->db->getLastInsertID());
    }

    public function getReport($shortUID) {
        $shortID = $this->decodeShortUID($shortUID);
        $vars = array(':shortID' => $shortID);
        $resReport = $this->db->prepared_query('SELECT data FROM short_links
                                    WHERE shortID=:shortID', $vars);
        if(!isset($resReport[0])) {
            return '';
        }
        session_write_close();
        header('Location: ' . $this->siteRoot . $resReport[0]['data']);
    }

    public function shortenReport($data) {
        $hash = hash('sha256', $data);

        $vars = array(':hash' => $hash);
        $res = $this->db->prepared_query('SELECT shortID FROM short_links
                                            WHERE hash=:hash', $vars);
        if(count($res) > 0) {
            return $this->encodeShortUID($res[0]['shortID']);
        }

        $vars = array(':data' => $data,
                      ':hash' => $hash);
        $this->db->prepared_query('INSERT INTO short_links (type, hash, data)
                                    VALUES ("report", :hash, :data)', $vars);
        return $this->encodeShortUID($this->db->getLastInsertID());
    }
}
