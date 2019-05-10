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
    public function create($signature, $recordID, $stepID, $dependencyID, $message, $signerPublicKey)
    {
        $vars = array(
            ':signature' => $signature,
            ':recordID' => $recordID,
            ':stepID' => $stepID,
            ':dependencyID' => $dependencyID,
            ':message' => $message,
            ':signerPublicKey' => $signerPublicKey,
            ':userID' => $this->login->getUserID(),
            ':timestamp' => time()
        );

        $res = $this->db->prepared_query(
            'INSERT INTO 
                signatures (signature, recordID, stepID, dependencyID, message, signerPublicKey, userID, timestamp)
                VALUES (:signature, :recordID, :stepID, :dependencyID, :message, :signerPublicKey, :userID, :timestamp)
                ON DUPLICATE KEY UPDATE signature=:signature, message=:message, signerPublicKey=:signerPublicKey, userID=:userID, timestamp=:timestamp',
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
        $signatures = $this->getSignature($recordID);
        $returnArray = array();
        for ($i = 0; $i < count($signatures); $i++)
        {
            $vars = array(
                ':recordID' => $recordID,
                ':actionType' => 'sign',
                ':signature_id' => $signatures[$i]['id'],
            );

            $res = $this->db->prepared_query(
                'SELECT * FROM
                action_history
                WHERE recordID=:recordID AND 
                  actionType=:actionType AND 
                  signature_id=:signature_id;',
                $vars
            );
            array_push($returnArray, $res[0]);
        }

        return $returnArray;
    }

    /**
     * Get signatures for record
     * @param $recordID int the id of the record the signature belongs to
     * @return array        array of all signatures and their info
     */
    public function getSignaturesByRecord($recordID)
    {
        $vars = array(
            ':recordID' => $recordID,
        );

        $sigs = $this->db->prepared_query(
            'SELECT * FROM 
                signatures
                WHERE recordID=:recordID;',
            $vars
        );

        $returnArray = array();

        for ($i = 0; $i < count($sigs); $i++)
        {
            $vars = array(
                ':recordID' => $recordID,
                ':actionType' => 'signed',
                ':signature_id' => $sigs[$i]['id'],
            );

            $res = $this->db->prepared_query(
                'SELECT * FROM
                action_history
                WHERE recordID=:recordID AND 
                  actionType=:actionType AND 
                  signature_id=:signature_id;',
                $vars
            );

            $nexusDB = $this->login->getNexusDB();
            $vars = array(':userName' => $res[0]['userID']);
            $res2 = $nexusDB->prepared_query(
                'SELECT * FROM employee 
                LEFT JOIN employee_data 
                USING (empUID) 
                WHERE indicatorID=6 AND 
                userName=:userName;', $vars);

            array_push($res[0], $res2[0]);
            array_push($returnArray, $res[0]);
        }
        return $returnArray;
    }
}
