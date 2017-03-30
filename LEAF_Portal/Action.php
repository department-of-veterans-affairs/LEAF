<?php
/************************
    Action for Form Generator
    Date Created: September 19, 2008

    TODO: finish replacing this with FormWorkflow.php
*/

class Action
{
    private $db;
    private $login;
    private $recordID;     
    public $siteRoot = '';

    function __construct($db, $login, $recordID)
    {
        $this->db = $db;
        $this->login = $login;
        $this->recordID = $recordID;
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://{$_SERVER['HTTP_HOST']}" . dirname($_SERVER['REQUEST_URI']) . '/';
    }

    public function postSubmit()
    {
        require_once 'VAMC_Directory.php';
        $dir = new VAMC_Directory;
        require_once 'Email.php';
        $email = new Email();

        $vars = array(':recordID' => $this->recordID);
        $record = $this->db->prepared_query('SELECT * FROM records
                                                LEFT JOIN services USING (serviceID)
                                                WHERE recordID=:recordID', $vars);

        $summary = $this->db->prepared_query('SELECT * FROM data WHERE recordID=:recordID AND indicatorID=16 AND series=1', $vars);    // indicator 16 for summary
        $summary[0]['data'] = strip_tags((isset($summary[0]['data']) ? $summary[0]['data'] : ''));

        if($record[0]['priority'] == -10) {
            $email->setSubject("(#{$this->recordID}) Emergency Request for " . $record[0]['service']);
            $email->setBody($this->siteRoot . "?a=committeeview&recordID={$this->recordID}\r\n\r\n{$record[0]['title']} (ID#: {$this->recordID})\r\n\r\n{$summary[0]['data']}");

//            $email->sendMail();
        }

        // send first alerting emails
        $vars = array(':recordID' => $this->recordID);
        $record = $this->db->prepared_query('SELECT * FROM records
                                                LEFT JOIN category_count USING (recordID)
                                                WHERE count > 0
                                                    AND recordID=:recordID', $vars);

        switch($record[0]['categoryID']) {
            default:
                // Service chief email
                $email = new Email();
                $email->setSubject("(#{$this->recordID}) Request for " . $record[0]['title']);
                $email->setBody("A new request has been submitted for your service. This request will not be processed until you concur.\r\n\r\nPlease visit the following link to review the request: {$this->siteRoot}?a=printview&recordID={$this->recordID}\r\n\r\n{$record[0]['title']} (ID#: {$this->recordID})\r\n\r\n{$summary[0]['data']}");

                $vars = array(':serviceID' => $record[0]['serviceID']);
                $chiefs = $this->db->prepared_query('SELECT * FROM service_chiefs
                                                        WHERE serviceID=:serviceID
                											AND active=1', $vars);
                foreach($chiefs as $chief) {
                    $dirRes = $dir->lookupLogin($chief['userID']);
                    $email->addRecipient($dirRes[0]['Email']);
                }
                $email->sendMail();
                break;
        }
    }

    public function sanitizeInput($in)
    {
        // strip out uncommon characters
        $in = preg_replace('/[^\040-\176]/', '', $in);
    
        // hard character limit of 65535
        $in = strlen($in) > 65535 ? substr($in, 0, 65535) : $in;
    
        $pattern = array('/&lt;table(\s.+)?&gt;/Ui',
                '/&lt;\/table&gt;/Ui',
                '/&lt;(\/)?br(\s.+)?\s\/&gt;/Ui',
                '/&lt;(\/)?(\S+)(\s.+)?&gt;/U',
                '/\b\d{3}-\d{2}-\d{4}\b/', // mask SSN
                '/(\<\/p\>\<\/p\>){2,}/',
                '/(\<p\>\<\/p\>){2,}/');
    
        $replace = array('<table class="table">',
                '</table>',
                '<\1br />',
                '<\1\2>',
                '###-##-####',
                '',
                '');
    
        $in = strip_tags(html_entity_decode($in), '<b><i><u><ol><li><br><p><table><td><tr>');
        $in = preg_replace($pattern, $replace, htmlspecialchars($in, ENT_QUOTES));
    
        // verify tag grammar
        $matches = array();
        preg_match_all('/\<(\/)?([A-Za-z]+)(\s.+)?\>/U', $in, $matches, PREG_PATTERN_ORDER);
        $openTags = array();
        $numTags = count($matches[2]);
        for($i = 0; $i < $numTags; $i++) {
            if($matches[2][$i] != 'br') {
                //echo "examining: {$matches[1][$i]}{$matches[2][$i]}\n";
                // proper closure
                if($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] > 0) {
                    $openTags[$matches[2][$i]]--;
                    // echo "proper\n";
                }
                // new open tag
                else if($matches[1][$i] == '') {
                    if(!isset($openTags[$matches[2][$i]])) {
                        $openTags[$matches[2][$i]] = 0;
                    }
                    $openTags[$matches[2][$i]]++;
                    // echo "open\n";
                }
                // improper closure
                else if($matches[1][$i] == '/' && isset($openTags[$matches[2][$i]]) && $openTags[$matches[2][$i]] <= 0) {
                    $in = '<' . $matches[2][$i] . '>' . $in;
                    $openTags[$matches[2][$i]]--;
                    // echo "improper\n";
                }
                // print_r($openTags);
            }
        }
    
        // close tags
        $tags = array_keys($openTags);
        foreach($tags as $tag) {
            while($openTags[$tag] > 0) {
                $in = $in . '</' . $tag . '>';
                $openTags[$tag]--;
            }
        }
    
        return $in;
    }
}
