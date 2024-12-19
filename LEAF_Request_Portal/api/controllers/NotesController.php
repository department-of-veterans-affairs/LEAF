<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

use App\Leaf\Db;
use App\Leaf\Logger\DataActionLogger;

class NotesController extends RESTfulResponse
{
    /**
     *
     * @var array
     */
    public $index = array();

    private $db;

    private $login;

    /**
     *
     * @var int
     */
    private $API_VERSION = 1;

    /**
     *
     * @var Note
     */
    private $note;

    /**
     *
     * @param Db $db
     * @param Login $login
     * @param DataActionLogger $dataActionLogger
     *
     * Created at: 10/7/2022, 9:45:22 AM (America/New_York)
     */
    public function __construct(Db $db, Login $login, DataActionLogger $dataActionLogger)
    {
        $this->db = $db;
        $this->login = $login;
        $this->note = new Note($db, $login, $dataActionLogger);
    }

    public function get($act)
    {
        /* This is never used right now.
        I didn't want to delete it in case it
        is ever needed in the future.


        if (is_numeric($act['args'][0])) {
            $query[$act['args'][0]]['recordID'] = $act['args'][0];

            $form = new Form($this->db, $this->login);
            $resRead = $form->checkReadAccess($query);

            if (isset($resRead[$act['args'][0]])) {
                $note = $this->note;

                $this->index['GET'] = new ControllerMap();

                $this->index['GET']->register('note/groupID/[digit]', function ($args) use ($note) {
                    return $note->getUndeletedNotesByRecordId($args[0]);
                });

                $this->index['GET']->register('note/[digit]', function ($args) use ($note) {
                    return $note->getNotesById($args[0]);
                });

                return $this->index['GET']->runControl($act['key'], $act['args']);
            } else {
                return 'Access denied';
            }
        } */
    }

    public function post($act)
    {
        if (is_numeric($act['args'][0])) {
            $query[$act['args'][0]]['recordID'] = $act['args'][0];

            $form = new Form($this->db, $this->login);
            $resRead = $form->checkReadAccess($query);

            if (isset($resRead[$act['args'][0]])) {
                $note = $this->note;

                $this->index['POST'] = new ControllerMap();

                $this->index['POST']->register('note/[digit]', function ($args) use ($note, $form) {
                    $params = array();
                    parse_str($_POST['form'], $params);

                    if (!empty($params['note'])) {
                        $params['recordID'] = $args[0];
                        $params['timestamp'] = time();
                        $params['userMetadata'] = $form->employee->getInfoForUserMetadata($params['userID'], false);
                        $posted_note_id = $note->postNote($params);
                        $posted_note = $note->getNotesById($posted_note_id);
                        $posted_note['user_name'] = $_SESSION['name'];
                        $posted_note['date'] = date('M j', $posted_note['timestamp']);
                    } else {
                        $posted_note = array('error' => 'Missing data, note cannot be blank.');
                    }

                    return $posted_note;
                });

                return $this->index['POST']->runControl($act['key'], $act['args']);
            } else {
                return 'Access denied';
            }
        } else {
            return 'Invalid data passed';
        }
    }

    public function delete($act)
    {
        // This method is unused in this class
        // This is required because of extending RESTfulResponse
    }
}
