<?php

/**
 * Handles functions related to signatures.
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
}
