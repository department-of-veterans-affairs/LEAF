<?php
/************************
    System controls
    Date: September 17, 2015

*/

class System
{
    private $db;
    private $login;
    public $siteRoot = '';

    function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
        
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on' ? 'https' : 'http';
        $this->siteRoot = "{$protocol}://{$_SERVER['HTTP_HOST']}" . dirname($_SERVER['REQUEST_URI']) . '/';

        include_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
    }

    public function setHeading($heading) {
    	$memberships = $this->login->getMembership();
    	if(!isset($memberships['groupID'][1])) {
    		return 'Admin access required';
    	}
    	$in = preg_replace('/[^\040-\176]/', '', XSSHelpers::sanitizeHTML($heading));
    	$vars = array(':input' => $in);

    	$this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="heading"', $vars);
    	return 1;
    }

    public function setSubHeading($subHeading) {
    	$memberships = $this->login->getMembership();
        if(!isset($memberships['groupID'][1])) {
    		return 'Admin access required';
    	}
    	$in = preg_replace('/[^\040-\176]/', '', XSSHelpers::sanitizeHTML($subHeading));
    	$vars = array(':input' => $in);
    
    	$this->db->prepared_query('UPDATE settings SET data=:input WHERE setting="subheading"', $vars);
    	return 1;
    }

    public function getReportTemplateList() {
    	$memberships = $this->login->getMembership();
    	if(!isset($memberships['groupID'][1])) {
    		return 'Admin access required';
    	}
    	$list = scandir('../templates/reports/');
    	$out = [];
    	foreach($list as $item) {
    		if(preg_match('/.tpl$/', $item)) {
    			$out[] = $item;
    		}
    	}
    	return $out;
    }
    
    public function newReportTemplate($in) {
    	$template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
    	if($template != $in
    			|| $template == 'example'
    			|| $template == '') {
    				return 'Invalid or reserved name.';
    	}
    	$template .= '.tpl';
    	$memberships = $this->login->getMembership();
    	if(!isset($memberships['groupID'][1])) {
    		return 'Admin access required';
    	}
    	$list = $this->getReportTemplateList();
    
    	if(array_search($template, $list) === false) {
    		copy("../templates/reports/example.tpl", "../templates/reports/{$template}");
    	}
    	else {
    		return 'File already exists';
    	}

    	return 'CreateOK';
    }
    
    public function getReportTemplate($in) {
    	$template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
    	if($template != $in) {
    		return 0;
    	}
    	$template .= '.tpl';
    	$memberships = $this->login->getMembership();
    	if(!isset($memberships['groupID'][1])) {
    		return 'Admin access required';
    	}
    	$list = $this->getReportTemplateList();
    
    	$data = [];
    	if(array_search($template, $list) !== false) {
    		if(file_exists("../templates/reports/{$template}")) {
    			$data['file'] = file_get_contents("../templates/reports/{$template}");
    		}
    	}
    	return $data;
    }
    
    public function setReportTemplate($in) {
    	$template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
    	if($template != $in
    			|| $template == 'example') {
    				return 0;
    	}
    	$template .= '.tpl';
    	$memberships = $this->login->getMembership();
    	if(!isset($memberships['groupID'][1])) {
    		return 'Admin access required';
    	}
    	$list = $this->getReportTemplateList();
    
    	if(array_search($template, $list) !== false) {
    		file_put_contents("../templates/reports/{$template}", $_POST['file']);
    	}
    }
    
    public function removeReportTemplate($in) {
    	$template = preg_replace('/[^A-Za-z0-9_]/', '', $in);
    	if($template != $in
    			|| $template == 'example') {
    				return 0;
    	}
    	$template .= '.tpl';
    	$memberships = $this->login->getMembership();
    	if(!isset($memberships['groupID'][1])) {
    		return 'Admin access required';
    	}
    	$list = $this->getReportTemplateList();
    
    	if(array_search($template, $list) !== false) {
    		if(file_exists("../templates/reports/{$template}")) {
    			return unlink("../templates/reports/{$template}");
    		}
    	}
    }
}
