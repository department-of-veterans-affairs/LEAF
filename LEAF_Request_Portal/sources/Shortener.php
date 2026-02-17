<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\Security;

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

        // For Jira Ticket:LEAF-2471/remove-all-http-redirects-from-code
//        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $protocol = 'https';
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

    public function decodeEntitiesForImport(array $formQuery): array {
        foreach ($formQuery as $recordID => $record) {
            $formQuery[$recordID]['title'] = html_entity_decode($record['title'], ENT_QUOTES);
            if (isset($record['s1'])) {
                foreach ($record['s1'] as $key => $entry) {
                    if (preg_match('/^id\d+$/', $key) && is_string($entry)) {
                        $formQuery[$recordID]['s1'][$key] = html_entity_decode($entry, ENT_QUOTES);
                    }
                }
            }
        }
        return $formQuery;
    }

    public function getFormQuery($shortUID) {
        $shortID = $this->decodeShortUID($shortUID);
        $vars = array(':shortID' => $shortID);
        $resReport = $this->db->prepared_query('SELECT data FROM short_links
                                    WHERE shortID=:shortID', $vars);
        if (!isset($resReport[0])) {
            return '';
        }

        if (isset($_GET['debug'])) {
            $query = json_decode(html_entity_decode(html_entity_decode($resReport[0]['data'])), true);

            if ($query == null) {
                return $resReport[0]['data'];
            }

            return $query;
        }

        $form = new Form($this->db, $this->login);
        $formQuery = $form->query($resReport[0]['data']);
        return $this->decodeEntitiesForImport($formQuery);
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

    public function getReport($shortUID)
    {
        $shortID = $this->decodeShortUID($shortUID);
        $vars = array(':shortID' => $shortID);
        $sql = 'SELECT `data`
                FROM `short_links`
                WHERE `shortID` = :shortID';
        $resReport = $this->db->prepared_query($sql, $vars);

        if (isset($resReport[0])) {
            $redirectPath = $resReport[0]['data'];

            // Use Security class to validate the raw redirect path
            // We need to temporarily encode it to use validateRedirect
            $encodedPath = base64_encode($redirectPath);

            $safeRedirect = Security::validateRedirect($encodedPath, HTTP_HOST, $this->siteRoot);

            // Only redirect if validation succeeded
            if ($safeRedirect !== $this->siteRoot) {
                session_write_close();
                header('Location: ' . $safeRedirect);
                exit();
            }

            // If validation failed, log it
            error_log("Shortener: Invalid redirect blocked for shortID: " . $shortID);
        }

        return '';
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
