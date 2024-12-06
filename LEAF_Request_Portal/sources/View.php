<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Views for forms
    Date Created: September 25, 2008

*/

namespace Portal;

use App\Leaf\Db;

class View
{
    /**
     *
     * @var Db
     */
    private $db;

    /**
     *
     * @var \Login
     */
    private $login;

    /**
     *
     * @param Db $db
     * @param \Login $login
     *
     * Created at: 10/14/2022, 8:25:14 AM (America/New_York)
     */
    public function __construct(Db $db, Login $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    /**
     *
     * @param int $recordID
     *
     * @return array
     *
     * Created at: 10/13/2022, 12:21:13 PM (America/New_York)
     */
    public function buildViewStatus(int $recordID): array
    {
        // check privileges
        $form = new Form($this->db, $this->login);

        if (!$form->hasReadAccess($recordID)) {
            $return_value = array();
        } else {
            $result = array();
            $dir = new VAMC_Directory;

            $vars = array(':recordID' => $recordID);
            $sql1 = 'SELECT time, description, actionText, stepTitle,
                        dependencyID, comment, userID, userMetadata
                     FROM action_history
                     LEFT JOIN dependencies USING (dependencyID)
                     LEFT JOIN workflow_steps USING (stepID)
                     LEFT JOIN actions USING (actionType)
                     WHERE recordID=:recordID
                     UNION
                     SELECT timestamp, "Note Added", "N/A", "N/A",
                        "N/A", note, userID, userMetadata
                     FROM notes
                     WHERE recordID = :recordID
                     AND deleted IS NULL
                     UNION
                     SELECT `timestamp`, "Email Sent", "N/A", "N/A",
                        "N/A", concat(`recipients`, "<br />", `subject`), "", ""
                     FROM `email_tracker`
                     WHERE recordID = :recordID
                     ORDER BY time ASC';

            $res = $this->db->prepared_query($sql1, $vars);

            foreach ($res as $tmp)
            {
                $packet = [];
                $packet['time'] = $tmp['time'];

                if (strtolower($tmp['description']) == 'note added') {
                    $packet['description'] = 'Note Added: ';
                } elseif (strtolower($tmp['description']) == 'email sent') {
                    $packet['description'] = 'Email Sent: ';
                } elseif (empty($tmp['description']) && empty($tmp['actionText'])) {
                    $packet['description'] = 'Action';
                } elseif(!empty($tmp['stepTitle']) && $tmp['dependencyID'] < 0) {
                    $packet['description'] = $tmp['stepTitle'] . ': ' . $tmp['actionText'];
                } else {
                    $packet['description'] = $tmp['description'] . ': ' . $tmp['actionText'];
                }

                $packet['comment'] = $tmp['comment'];

                if (!empty($tmp['userID'])) {
                    $name = $tmp['userID'];
                    if(isset($tmp['userMetadata'])) {
                        $umd = json_decode($tmp['userMetadata'], true);
                        $display =  trim($umd['firstName'] . " " . $umd['lastName']);
                        $name = !empty($display) ? $display : $name;
                    }
                    $packet['userName'] = $name;
                }

                $result[] = $packet;
            }

            $sql2 = 'SELECT signature, userID, timestamp, stepTitle
                     FROM signatures
                     LEFT JOIN workflow_steps USING (stepID)
                     WHERE recordID=:recordID';

            $res = $this->db->prepared_query($sql2, $vars);

            foreach ($res as $tmp) {
                $packet = [];
                $packet['time'] = $tmp['timestamp'];
                $packet['description'] = $tmp['stepTitle'] . ': Digitally Signed';
                $packet['comment'] = 'Signature Hash: ' . $tmp['signature'];

                if (!empty($tmp['userID'])) {
                    $user = $dir->lookupLogin($tmp['userID']);
                    $name = isset($user[0]) ? "{$user[0]['Fname']} {$user[0]['Lname']}" : $tmp['userID'];
                    $packet['userName'] = $name;
                }

                $result[] = $packet;
            }

            usort($result, [self::class, 'sortArray']);

            $return_value = $result;
        }

        return $return_value;

    }

    /**
     *
     * @param string $userID
     *
     * @return array
     *
     * Created at: 10/14/2022, 8:25:46 AM (America/New_York)
     */
    public function buildViewBookmarks(string $userID): array
    {
        $var = array(':bookmarkID' => 'bookmark_' . $userID);
        $sql =
           'SELECT tags.recordID, stepBgColor, stepFontColor, actionIcon, stepTitle,
                actionTextPasttense, title, submitted, lastStatus
            FROM tags
            LEFT JOIN records USING (recordID)
            LEFT JOIN (
                SELECT recordID, actionType, dependencyID
                FROM action_history
                ORDER BY actionID DESC) lj1 USING (recordID)
            LEFT JOIN actions USING (actionType)
            LEFT JOIN step_dependencies USING (dependencyID)
            LEFT JOIN workflow_steps USING (stepID)
            WHERE tag = :bookmarkID
            GROUP BY recordID';

        $res = $this->db->prepared_query($sql, $var);

        return (array) $res;
    }

    /**
     *
     * @param array $a
     * @param array $b
     *
     * @return int
     *
     * Created at: 10/14/2022, 8:41:59 AM (America/New_York)
     */
    private static function sortArray(array $a, array $b): int
    {
        return $a['time'] - $b['time'];
    }
}
