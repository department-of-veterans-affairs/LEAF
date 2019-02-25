<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use RequestPortal\Data\Model\Record;
use RequestPortal\Data\Repositories\Contracts\RecordsRepository;

class RecordsDao extends CachedDbDao implements RecordsRepository
{
    protected $tableName = 'records';

    /**
     * Create a new Record
     *
     * @var Record
     */
    public function create($record)
    {
        if ($record instanceof Record)
        {
            return $this->getConn()->insertGetId(array(
                'date' => $record->date,
                'serviceID' => $record->serviceID,
                'userID' => $record->userID,
                'title' => $record->title,
                'priority' => $record->priority,
            ));
        }
    }

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getById($recordID)
    {
        return $this->getConn()->where('recordID', $recordID)->get();
    }

    public function delete($recordID)
    {
        return $this->getConn()->where('recordID', $recordID)->update(array('deleted' => time()));
    }

    public function restore($recordID)
    {
        return $this->getConn()->where('recordID', $recordID)->update(array('deleted' => 0));
    }

    /**
     * Check if need to know mode is enabled for any form, or a specific form
     * @param int $recordID
     * @return boolean
     * 
     * TODO caching
     */
    public function isNeedToKnow($recordID = null)
    {
        // if (isset($this->cache['isNeedToKnow_' . $recordID]))
        // {
        //     return $this->cache['isNeedToKnow_' . $recordID];
        // }
        if ($recordID == null)
        {
            $res = $this->getConnForTable('categories')
            ->where('needToKnow', 1)
            ->get();
            if (count($res) == 0)
            {
                //$this->cache['isNeedToKnow_' . $recordID] = false;

                return false;
            }
        }
        else
        {
            $res = $this->getConnForTable('category_count')
            ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
            ->where([['recordID', $recordID],['needToKnow', 1],['count', '>', 0]])
            ->get();

            if (count($res) == 0)
            {
                //$this->cache['isNeedToKnow_' . $recordID] = false;

                return false;
            }
        }

        //$this->cache['isNeedToKnow_' . $recordID] = true;

        return true;
    }

    public function getForm($recordID, $limitCategory = null)
    {
        $jsonRootIdx = -1;

        $json['label'] = 'name';
        $json['identifier'] = 'jsonIdx';

        if ($limitCategory == null)
        {
            // pull category counts
            $vars = array(':recordID' => $recordID);
            $res2 = $this->db->prepared_query('SELECT * FROM category_count
                                                    LEFT JOIN categories USING (categoryID)
                                                    WHERE recordID = :recordID
                                                        AND count > 0
                                                    ORDER BY sort', $vars);
        }
        else
        {
            $vars = array(':categoryID' => XSSHelpers::xscrub($limitCategory));
            $res2 = $this->db->prepared_query('SELECT * FROM categories
                                                    WHERE categoryID = :categoryID', $vars);
            $res2[0]['count'] = 1;
        }

        foreach ($res2 as $catType)
        {
            for ($i = 1; $i <= $catType['count']; $i++)
            {
                $tmp['name'] = $catType['count'] > 1
                                    ? $catType['categoryName'] . ' #' . $i
                                    : $catType['categoryName'];
                $tmp['type'] = 'form';
                $tmp['jsonIdx'] = --$jsonRootIdx;
                $tmp['series'] = $i;
                $tmp['children'] = $this->buildFormJSONStructure($catType['categoryID'], $i);
                $json['items'][] = $tmp;
            }
        }

        return $json;
    }

    public function getFormJSON($recordID)
    {
        $json = $this->getForm($recordID);

        return json_encode($json);
    }
}
