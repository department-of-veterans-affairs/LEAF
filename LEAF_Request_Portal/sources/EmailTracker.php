<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
 *  Email Template Handler
 */

namespace Portal;

use App\Leaf\Db;

class EmailTracker
{
    protected $db;

    public function __construct(Db $db)
    {
        $this->db = $db;
    }

    public function getEmailsSent(): array
    {
        $vars = [];
        $sql = 'SELECT `recordID`, `timestamp`, `recipients`, `subject`
                FROM `email_tracker`';

        $return_value = $this->db->prepared_query($sql, $vars);

        return $return_value;
    }

    public function getEmailsSentByRecordId(int $id): array
    {
        $vars = array(':recordID' => $id);
        $sql = 'SELECT `recordID`, `timestamp`, `recipients`, `subject`
                FROM `email_tracker`
                WHERE `recordID` = :recordID
                ORDER BY `timestamp` DESC';

        $return_value = $this->db->prepared_query($sql, $vars);

        return $return_value;
    }

    public function postEmailTracker(int $recordID, string $recipients, string $subject)
    {
        $vars = array(':recordID' => $recordID,
                ':timestamp' => time(),
                ':recipients' => $recipients,
                ':subject' => $subject);
        $sql = 'INSERT INTO `email_tracker` (`recordID`, `timestamp`, `recipients`, `subject`)
                VALUES (:recordID, :timestamp, :recipients, :subject)';

        $this->db->prepared_query($sql, $vars);
    }
}