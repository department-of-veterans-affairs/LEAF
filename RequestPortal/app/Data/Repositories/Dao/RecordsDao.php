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

    protected $cache = array();

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
                'empUID' => $record->empUID,
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
     */
    public function isNeedToKnow($recordID = null)
    {
        if (isset($this->cache['isNeedToKnow_' . $recordID]))
        {
            return $this->cache['isNeedToKnow_' . $recordID];
        }
        if ($recordID == null)
        {
            $res = $this->getConnForTable('categories')
            ->where('needToKnow', 1)
            ->get();
            if (count($res) == 0)
            {
                $this->cache['isNeedToKnow_' . $recordID] = false;

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
                $this->cache['isNeedToKnow_' . $recordID] = false;

                return false;
            }
        }

        $this->cache['isNeedToKnow_' . $recordID] = true;

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
            $res2 = $this->getConnForTable('category_count')
                ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
                ->where([['recordID', $recordID],['count', '>', 0]])
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
        }
        else
        {
            $res2 = $this->getConnForTable('categories')
                ->where('categoryID', $limitCategory)
                ->get()
                ->toArray();
            $res2[0]['count'] = 1;
        }

        foreach ($res2 as $catType)
        {
            $catType = (array) $catType;
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

    public function buildFormJSONStructure($categoryID, $series = 1)
    {
        $categoryID = ($categoryID == null) ? 'general' : $categoryID;

        if (!isset($this->cache["categoryID{$categoryID}_indicators"]))
        {
            $res = $this->getConnForTable('indicators')
                ->where([['categoryID', $categoryID],['disabled', 0]])
                ->wherenull('parentID')
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
            
            $this->cache["categoryID{$categoryID}_indicators"] = $res;
        }
        else
        {
            $res = $this->cache["categoryID{$categoryID}_indicators"];
        }

        $indicators = array();
        $counter = 1;
        foreach ($res as $ind)
        {
            $ind = (array) $ind;
            $desc = $ind['description'] != '' ? $ind['description'] : $ind['name'];
            $indicator['name'] = "$series.$counter: " . strip_tags($desc);
            $indicator['desc'] = strip_tags($desc);
            $indicator['type'] = $categoryID;
            $indicator['jsonIdx'] = $ind['indicatorID'] . '.' . $series;
            $indicator['series'] = $series;
            $indicator['format'] = $ind['format'];
            $indicator['indicatorID'] = $ind['indicatorID'];
            $indicators[] = $indicator;
            $counter++;
        }

        return $indicators;
    }

    public function getFormJSON($recordID)
    {
        $json = $this->getForm($recordID);

        return json_encode($json);
    }

    public function addToCategoryCount($recordID, $categoryID)
    {
        $res = $this->getConnForTable('category_count')
            ->updateOrInsert(['recordID' => $recordID, 'categoryID' => $categoryID], ['count' => 1]);
    }

    public function switchCategoryCount($recordID, $categories)
    {
        $this->getConnForTable('category_count')
            ->where('recordID', $recordID)
            ->update(['count' => 0]);

        foreach ($categories as $category)
        {
            $this->addFormType($recordID, $category);
        }

        return 1;
    }
}
