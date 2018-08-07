<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

class Signature
{
    private $db;

    private $login;

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    /**
     * Create a new Signature.
     *
     * @param signature string  the actual signature fingerprint
     * @param recordID  int     the id of the record the signature belongs to
     * @param message   string  the message that was signed
     */
    public function create($signature, $recordID, $message)
    {
        $vars = array(
            ':signature' => $signature,
            ':recordID' => $recordID,
            ':message' => $message,
        );

        $res = $this->db->prepared_query(
            'INSERT INTO 
                signatures (signature, recordID, message)
                VALUES (:signature, :recordID, :message);',
            $vars
        );

        return $this->db->getLastInsertID();
    }

    public function getSignature($recordID)
    {
        $vars = array(
            ':recordID' => $recordID,
        );

        $res = $this->db->prepared_query(
            'SELECT * FROM 
                signatures
                WHERE recordID=:recordID;',
            $vars
        );

        return $res;
    }

    public function getSignatureHistory($recordID)
    {
        $vars = array(
            ':recordID' => $recordID,
            ':actionType' => 'sign',
        );

        $res = $this->db->prepared_query(
            'SELECT * FROM
                action_history
                WHERE recordID=:recordID AND 
                  actionType=:actionType
                  ORDER BY signature_id;',
            $vars
        );

        return $res;
    }
}
