<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/**
 * Notes Model - Only db interaction allowed in this class.
 *
 * created: October 3, 2022
 */

namespace Portal;

use App\Leaf\Db;
use App\Leaf\Logger\DataActionLogger;

class Note
{
    /**
     *
     * @var Db
     */
    private $db;

    /**
     *
     * @var Login
     */
    private $login;

    /**
     *
     * @var DataActionLogger
     */
    private $dataActionLogger;

    /**
     *
     * @param Db $db
     * @param Login $login
     * @param DataActionLogger $dataActionLogger
     *
     * Created at: 10/3/2022, 10:21:10 AM (America/New_York)
     */
    public function __construct(Db $db, Login $login, DataActionLogger $dataActionLogger)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dataActionLogger = $dataActionLogger;
    }


    /**
     * Get all undeleted notes by recordId sort by noteID DESC to show the latest note at the top
     *
     * @param int $recordID
     *
     * @return array
     *
     * Created at: 10/3/2022, 11:18:56 AM (America/New_York)
     */
    public function getUndeletedNotesByRecordId(int $recordID): array
    {
        $sql_vars = array(':recordID' => $recordID);
        $sql = 'SELECT recordID, note, timestamp, userID
                FROM notes
                WHERE recordID=:recordID
                AND deleted IS NULL
                ORDER BY noteID DESC';

        $return_value = $this->db->prepared_query($sql, $sql_vars);

        return (array) $return_value;
    }

    /**
     *
     * @param int $id
     *
     * @return array
     *
     * Created at: 10/5/2022, 3:20:27 PM (America/New_York)
     */
    public function getNotesById(int $id): array
    {
        $sql_vars = array(':noteID' => $id);
        $sql = 'SELECT recordID, note, timestamp, userID
                FROM notes
                WHERE noteID=:noteID';

        $return_value = $this->db->prepared_query($sql, $sql_vars);

        return (array) $return_value[0];
    }

    /**
     * Posting notes to db.
     * Required fields to post a note are: recordID, note, userID, timestamp
     *
     * @param array $db_fields - sanitized array of key value pairs that will be parsed here for entry into the db.
     *
     * @return int|array
     *
     * Created at: 10/4/2022, 7:49:50 AM (America/New_York)
     */
    public function postNote(array $db_fields): int|array
    {
        if (!empty($db_fields['note'])) {
            $sql_vars = array();
            $field_list = array();
            $value_list = array();

            foreach ($db_fields as $key => $field) {
                $sql_vars[':'.$key] = $field;
                $field_list[] = $key;
                $value_list[] = ':'.$key;
            }

            $sql = 'INSERT INTO notes (' . implode(',', $field_list) . ') VALUES (' . implode(',', $value_list) . ')';

            $this->db->prepared_query($sql, $sql_vars);

            $return_value = (int) $this->db->getLastInsertID();
        } else {
            $return_value = array('error' => 'Missing data, note cannot be blank.');
        }

        return $return_value;
    }

    /**
     * update notes in Db - most likely just to soft delete, occasionally update the note itself
     * Required fields to update note are: noteId, {any field to be updated}
     *
     * @param array $db_fields - sanitized array of key value pairs that will be parsed here for entry into the db.
     *
     * @return array
     *
     * Created at: 10/5/2022, 8:38:31 AM (America/New_York)
     */
    public function updateNote(array $db_fields): array
    {
        $sql_vars = array();
        $field_list = array();

        foreach ($db_fields as $key => $field) {
            $sql_vars[':'.$key] = $field;

            if ($key != 'noteID') {
                $field_list[] = $key.'=:'.$field;
            } else {
                $where_condition = $key.'=:'.$field;
            }
        }

        $sql = 'UPDATE notes SET ' . implode(',', $field_list) . ' WHERE ' . $where_condition;

        $return_value = $this->db->prepared_query($sql, $sql_vars);

        return (array) $return_value;
    }
}
