<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

require '../sources/Note.php';

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../../libs/php-commons/XSSHelpers.php';
}

class NotesController extends RESTfulResponse
{
    public $index = array();

    private $API_VERSION = 1;

    private $note;

    public function __construct($db, $login, $dataActionLogger)
    {
        $this->note = new Note($db, $login, $dataActionLogger);
    }

    public function get($act)
    {
        $note = $this->note;

        $this->index['GET'] = new ControllerMap();

        $this->index['GET']->register('note/groupID/[digit]', function ($args) use ($note) {
            return $note->getUndeletedNotesByRecordId($args[0]);
        });

        $this->index['GET']->register('note/[digit]', function ($args) use ($note) {
            return $note->getNotesById($args[0]);
        });

        return $this->index['GET']->runControl($act['key'], $act['args']);
    }

    public function post($act)
    {
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
    }
}
