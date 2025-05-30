<?php
/************************
    Template for custom events
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: August 12, 2011
    Updated: May 27, 2025
    Description:
    Template for events triggered by RMC workflow actions
*/

namespace Portal;

use App\Leaf\Db;
use Exception;

class CustomEvent_check_db_schema
{
    private $db;        // Object, Database connection (Launchpad)
    private $login;     // Object, Login information for the current user
    private $dir;       // Object, Phone directory lookup
    private $email;     // Object, Email control
    private $eventInfo; // Array, The event info that triggers this event
                        //   (recordID, workflowID, stepID, actionType, comment)
    private $siteRoot;  // String, URL to the root directory

    private $form;
    private $formWorkflow;

    private array $site_types = array('portal' => 1, 'orgchart' => 1);
    private array $table_names = array(
        'actions' => 1,
        'workflow_routes' => 1,
        'route_events' => 1,
    );
    private string $log_file_name = 'schema_checker_log.txt';
    private $log_file;

    function __construct($db, $login, $dir, $email, $siteRoot, $eventInfo)
    {
        $this->db = $db;
        $this->login = $login;
        $this->dir = $dir;
        $this->email = $email;
        $this->siteRoot = $siteRoot;
        $this->eventInfo = $eventInfo;
    }

    public function checkDatabaseVersion($dbversion, $db_name = '') {
        $vars = array(':dbversion' => $dbversion);
        $sql = "SELECT `data` FROM settings
            WHERE setting='dbversion' AND `data` != :dbversion";

        $outofdate = $this->db->prepared_query($sql, $vars) ?? [];
        
        foreach($outofdate as $rec) {
            fwrite(
                $this->log_file,
                "DB: " . $db_name . " at -V " . $rec['data'] . PHP_EOL
            );
        }
    }

    public function checkTableConstraintName($tableName = '') {
        fwrite(
            $this->log_file,
            "Foreign key constraints for table: ". $tableName . PHP_EOL
        );

        $vars = array(':table_name' => $tableName);
        $sql = "SELECT table_name, CONSTRAINT_SCHEMA, CONSTRAINT_NAME, COUNT(CONSTRAINT_NAME) AS c_count
            FROM information_schema.table_constraints
            WHERE CONSTRAINT_TYPE = 'FOREIGN KEY' AND
            table_name=:table_name 
            GROUP BY CONSTRAINT_NAME
            ORDER BY CONSTRAINT_NAME";
        
        $schema_records = $this->db->prepared_query($sql, $vars);
        
        foreach($schema_records as $rec) {
            fwrite(
                $this->log_file,
                "DB: " . $rec['CONSTRAINT_SCHEMA'] . ", constraint name: ". $rec['CONSTRAINT_NAME'] . ", count: " . $rec['c_count'] . PHP_EOL
            );
        }
    }

    public function execute()
    {
        $time_start = date_create();
        $this->log_file = fopen($this->log_file_name, "w") or die("unable to open file");

        $this->form = new Form($this->db, $this->login);

        $recordID = $this->eventInfo['recordID'];
        //eventInfo: recordID,workflowID,stepID,actionType,comment,fields
        
        $task = $this->form->getIndicator(449, 1, $recordID)[449]['value'];
        fwrite(
            $this->log_file,
            "Starting task: ". $task . PHP_EOL
        );

        $site_type = $this->form->getIndicator(450, 1, $recordID)[450]['value'] ?? '';
        $dbversion = $this->form->getIndicator(453, 1, $recordID )[453]['value'] ?? '';
        $tableName = $this->form->getIndicator(451, 1, $recordID )[451]['value'] ?? '';

        switch($task) {
            case 'portal_version':
            case 'orgchart_version':
                if($this->site_types[$site_type] === 1 && is_numeric($dbversion)) {
                    $vars = array(':site_type' => $site_type);
                    $sql = 'SELECT portal_database, orgchart_database
                        FROM sites 
                        WHERE site_type=:site_type';
                    
                    $sites = $this->db->prepared_query($sql, $vars);

                    foreach($sites as $site) {
                        $rec_db = $site_type === 'portal' ?
                            $site['portal_database'] :
                            $site['orgchart_database'];

                        try {
                            $this->db->query("USE `{$rec_db}`");
                            $this->checkDatabaseVersion($dbversion, $rec_db);

                        } catch (Exception $e) {
                            fwrite(
                                $this->log_file,
                                "Caught Exception (db connect): " . $rec_db . " " . $e->getMessage() . PHP_EOL
                            );
                        }
                    }
                }
                break;
            case 'foreign_key_constraint';
                if($this->table_names[$tableName] === 1) {
                    $this->checkTableConstraintName($tableName);
                }
                break;
            default:
            break;
        }

        $time_end = date_create();
        $time_diff = date_diff($time_start, $time_end);
        $ftime_diff = $time_diff->format('%H hr, %i min, %S sec, %f mcr');

        $msg = "Processed task: ". $task . " (". $ftime_diff .")";
        fwrite(
            $this->log_file,
            $msg . PHP_EOL
        );
        fclose($this->log_file);


        $this->db->query("USE `national_leaf_launchpad`");
        $currDB = $this->db->query('SELECT DATABASE()')[0];

        $uploadIndID = 452;
        $series = 1;
        $uploadDir = isset(Config::$uploadDir) ? Config::$uploadDir : UPLOAD_DIR;
        $uploadDir = $uploadDir === UPLOAD_DIR ? '../' . UPLOAD_DIR : $uploadDir;

        $sourceFile = $this->log_file_name;
        $destFile = $uploadDir . $recordID . '_' . $uploadIndID . '_' . $series . '_' . $this->log_file_name;

        $this->formWorkflow = new FormWorkflow($this->db, $this->login, $recordID);

        if (!rename($sourceFile, $destFile)) {
            $errors = error_get_last();
            $msg = $errors['message'];
            echo $msg;
            $this->formWorkflow->setStep(65, true, $msg);

        } else {
            $_POST['CSRFToken'] = $_SESSION['CSRFToken'];
            $_POST[$uploadIndID] = $this->log_file_name;

            $strSQL = 'SELECT userID FROM records WHERE recordID=' . $recordID;
            $recres = $this->db->query($strSQL);
            $author = $this->dir->lookupLogin($recres[0]['userID']);

            print_r($author, true);
            
            $this->form->doModify($recordID);

            $this->formWorkflow->setStep(64, true, $msg);
            /*
            $this->email->addRecipient($author[0]['Email']);
        
            $this->email->setSubject("Log ready for " . $recordID);

            $emailBody = "Hello " . $author[0]['Fname'] . " " . $author[0]['Lname'] . ",\r\n\r\n".
                "A log for request " . $recordID . " has been uploaded.";

            $this->email->emailBody = $this->email->setContent(
                'custom_override/LEAF_main_email_template.tpl',
                'emailBody',
                $emailBody
            ); 
            $this->email->setSender("LEAF@va.gov");
            $this->email->sendMail($recordID);
            */
        }
    }
}