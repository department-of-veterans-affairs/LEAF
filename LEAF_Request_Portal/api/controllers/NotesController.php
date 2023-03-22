<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

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
     * @param \Leaf\Db $db
     * @param Login $login
     * @param \Leaf\DataActionLogger $dataActionLogger
     *
     * Created at: 10/7/2022, 9:45:22 AM (America/New_York)
     */
    public function __construct(\Leaf\Db $db, Login $login, \Leaf\DataActionLogger $dataActionLogger)
    {
        $this->db = $db;
        $this->login = $login;
        $this->note = new Note($db, $login, $dataActionLogger);
    }

    public function get($act)
    {
        if (is_numeric($act['args'][0])) {
            $query[$act['args']['recordID']]['recordID'] = $act['args'][0];

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
        }
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

                $this->index['POST']->register('note/[digit]', function ($args) use ($note) {
                    $params = array();
                    parse_str($_POST['form'], $params);

                    $params['recordID'] = $args[0];
                    $params['timestamp'] = time();

                    $posted_note_id = $note->postNote($params);
                    $posted_note = $note->getNotesById($posted_note_id);
                    $posted_note['user_name'] = $_SESSION['name'];
                    $posted_note['date'] = date('M j', $posted_note['timestamp']);

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
