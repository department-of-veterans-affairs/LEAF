<?php
/************************
    Tag (small helper function to help map relationships between tags)
    Date: April 17, 2015
    
*/

namespace Orgchart;

class Tag
{
    protected $db;
    protected $login;

    private $cache = [];

    function __construct($db, $login)
    {
    	$this->db = $db;
    	$this->login = $login;
    }

    /**
     * Given a tag, returns the parent tag
     * @param string $tag
     */
    function getParent($tag)
    {
    	$cacheHash = 'getParent_' . $tag;
    	if(isset($this->cache[$cacheHash])) {
    		return $this->cache[$cacheHash];
    	}

    	$vars = array(':tag' => $tag);
    	$res = $this->db->prepared_query('SELECT * FROM tag_hierarchy WHERE tag=:tag', $vars);
    	$this->cache[$cacheHash] = $res[0]['parentTag'];
    	return $res[0]['parentTag'];
    }

    /**
     * Set a tag's parent tag
     * @param string $tag
     */
    function setParent($tag, $parentTag)
    {
    	$memberships = $this->login->getMembership();
    	if(!isset($memberships['groupID'][1])) {
    		throw new Exception('Administrator access required');
    	}

    	if($tag == 'service') {
    		$vars = array(':tag' => $tag);
    		$res = $this->db->prepared_query('SELECT * FROM tag_hierarchy WHERE tag=:tag', $vars);

    		$vars = array(':parentTagNew' => $parentTag,
    					  ':parentTagOld' => $res[0]['parentTag']
    		);
    		$this->db->prepared_query('UPDATE tag_hierarchy SET tag=:parentTagNew WHERE tag=:parentTagOld', $vars);
    		$this->db->prepared_query('UPDATE group_tags SET tag=:parentTagNew WHERE tag=:parentTagOld', $vars);

    		$vars = array(':tag' => $tag,
    					  ':parentTag' => $parentTag
    		);
    		$this->db->prepared_query('UPDATE tag_hierarchy SET parentTag=:parentTag WHERE tag=:tag', $vars);
    	}
    	$this->updateLastModified();
    	return 1;
    }

    function getAll()
    {
    	$vars = array();
    	$res = $this->db->prepared_query('SELECT * FROM tag_hierarchy', $vars);
    	return $res;    	
    }
}
