<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Tag (small helper function to help map relationships between tags)
    Date: April 17, 2015

*/

namespace Orgchart;

class Tag extends Data
{
    protected $dataTable = 'tag_hierarchy';

    protected $dataHistoryTable = '';

    protected $dataTableUID = '';

    protected $dataTableDescription = '';

    protected $dataTableCategoryID = 0;

    protected $db;

    protected $login;

    protected $cache = array();

    public function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;
    }

    public function initialize()
    {
        $this->setDataTable($this->dataTable);
        $this->setDataHistoryTable($this->dataHistoryTable);
        $this->setDataTableUID($this->dataTableUID);
        $this->setDataTableDescription($this->dataTableDescription);
        $this->setDataTableCategoryID($this->dataTableCategoryID);
    }

    /**
     * Given a tag, returns the parent tag
     * @param string $tag
     */
    public function getParent($tag)
    {
        $cacheHash = 'getParent_' . $tag;
        if (isset($this->cache[$cacheHash]))
        {
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
    public function setParent($tag, $parentTag)
    {
        $memberships = $this->login->getMembership();
        if (!isset($memberships['groupID'][1]))
        {
            throw new Exception('Administrator access required');
        }

        if ($tag == 'service')
        {
            $vars = array(':tag' => $tag);
            $res = $this->db->prepared_query('SELECT * FROM tag_hierarchy WHERE tag=:tag', $vars);

            $vars = array(':parentTagNew' => $parentTag,
                          ':parentTagOld' => $res[0]['parentTag'],
            );
            $this->db->prepared_query('UPDATE tag_hierarchy SET tag=:parentTagNew WHERE tag=:parentTagOld', $vars);
            $this->db->prepared_query('UPDATE group_tags SET tag=:parentTagNew WHERE tag=:parentTagOld', $vars);

            $vars = array(':tag' => $tag,
                          ':parentTag' => $parentTag,
            );
            $this->db->prepared_query('UPDATE tag_hierarchy SET parentTag=:parentTag WHERE tag=:tag', $vars);
        }

        // update lastModified timestamp
        $time = time();
        $vars = array(':cacheID' => 'lastModified',
                      ':data' => $time,
                      ':cacheTime' => $time, );
        $this->db->prepared_query('INSERT INTO cache (cacheID, data, cacheTime)
                                       VALUES (:cacheID, :data, :cacheTime)
                                       ON DUPLICATE KEY UPDATE data=:data, cacheTime=:cacheTime', $vars);

        return 1;
    }

    public function getAll()
    {
        $vars = array();
        $res = $this->db->prepared_query('SELECT * FROM tag_hierarchy', $vars);

        return $res;
    }

    /**
     * @param int $id
     * @param string $tag
     *
     * @return array
     *
     * Created at: 8/16/2023, 8:57:05 AM (America/New_York)
     */
    public function groupIsTagged(int $id, string $tag): array
    {
        $vars = array(':groupID' => $id,
                    ':tag' => $tag);
        $sql = 'SELECT `groupID`, `tag`
                FROM `group_tags`
                WHERE `groupID` = :groupID
                AND `tag` = :tag';

        $return_value = $this->db->pdo_select_query($sql, $vars);

        return $return_value;
    }
}