<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Nexus\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Nexus\Data\Repositories\Contracts\DataRepository;

class DataDao extends CachedDbDao implements DataRepository
{
    protected $connectionName = "nexus";

    protected $dataTable = '';

    protected $dataHistoryTable = '';

    protected $dataTagTable = '';

    protected $dataTableUID = '';

    protected $dataTableDescription = '';

    protected $dataTableCategoryID = 0;

    private $cache = array();

    /**
     * Retrieve all data if no indicatorID is given
     * @param int $UID
     * @param int $indicatorID
     * @return array
     */
    public function getAllData($UID, $indicatorID = 0)
    {
        if (!is_numeric($indicatorID))
        {
            return array();
        }

        $vars = array();
        $res = array();

        $cacheHash = "getAllData_{$UID}_{$indicatorID}";
        if (isset($this->cache[$cacheHash]))
        {
            return $this->cache[$cacheHash];
        }

        if (!isset($this->cache["getAllData_{$indicatorID}"]))
        {
            if ($indicatorID != 0)
            {
                $res = $this->getConnForTable('indicators')
                ->where([['categoryID', $this->dataTableCategoryID],['disabled', 0],['indicatorID', $indicatorID]])
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
            }
            else
            {
                $res = $this->getConnForTable('indicators')
                ->where([['categoryID', $this->dataTableCategoryID],['disabled', 0]])
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
            }
            $this->cache["getAllData_{$indicatorID}"] = $res;
        }
        else
        {
            $res = $this->cache["getAllData_{$indicatorID}"];
        }

        $data = array();

        foreach ($res as $item)
        {
            $idx = $item['indicatorID'];
            $data[$idx]['indicatorID'] = $item['indicatorID'];
            $data[$idx]['name'] = isset($item['name']) ? $item['name'] : '';
            $data[$idx]['format'] = isset($item['format']) ? $item['format'] : '';
            if (isset($item['description']))
            {
                $data[$idx]['description'] = $item['description'];
            }
            if (isset($item['default']))
            {
                $data[$idx]['default'] = $item['default'];
            }
            if (isset($item['html']))
            {
                $data[$idx]['html'] = $item['html'];
            }
            $data[$idx]['required'] = $item['required'];
            if ($item['encrypted'] != 0)
            {
                $data[$idx]['encrypted'] = $item['encrypted'];
            }
            $data[$idx]['data'] = '';
            $data[$idx]['isWritable'] = 0; //temp
            //$data[$idx]['author'] = '';
            //$data[$idx]['timestamp'] = 0;

            // handle checkboxes/radio buttons
            $inputType = explode("\n", $item['format']);
            $numOptions = count($inputType) > 1 ? count($inputType) : 2;
            if (count($inputType) != 1)
            {
                for ($i = 1; $i < $numOptions; $i++)
                {
                    $inputType[$i] = isset($inputType[$i]) ? trim($inputType[$i]) : '';
                    $data[$idx]['options'][] = $inputType[$i];
                }
            }

            $data[$idx]['format'] = trim($inputType[0]);
        }

        if (count($res) > 0)
        {
            $indicatorList = '';
            foreach ($res as $field)
            {
                if (is_numeric($field['indicatorID']))
                {
                    $indicatorList .= "{$field['indicatorID']},";
                }
            }
            $res2 = $this->getConnForTable($this->dataTable)
            ->select('data', 'timestamp', 'indicatorID')
            ->whereIn([['indicatorID', $indicatorList]])
            ->where([[$this->dataTableUID, $UID]])
            ->orderBy('sort', 'asc')
            ->get()
            ->toArray();

            foreach ($res2 as $resIn)
            {
                $idx = $resIn['indicatorID'];
                $data[$idx]['data'] = isset($resIn['data']) ? $resIn['data'] : '';
                $data[$idx]['data'] = @unserialize($data[$idx]['data']) === false ? $data[$idx]['data'] : unserialize($data[$idx]['data']);
                if ($data[$idx]['format'] == 'json')
                {
                    $data[$idx]['data'] = html_entity_decode($data[$idx]['data']);
                }
                if ($data[$idx]['format'] == 'fileupload')
                {
                    $tmpFileNames = explode("\n", $data[$idx]['data']);
                    $data[$idx]['data'] = array();
                    foreach ($tmpFileNames as $tmpFileName)
                    {
                        if (trim($tmpFileName) != '')
                        {
                            $data[$idx]['data'][] = $tmpFileName;
                        }
                    }
                }
                if (isset($resIn['author']))
                {
                    $data[$idx]['author'] = $resIn['author'];
                }
                if (isset($resIn['timestamp']))
                {
                    $data[$idx]['timestamp'] = $resIn['timestamp'];
                }
            }

            // apply access privileges
            $privilegesData = $this->login->getIndicatorPrivileges(array_keys($data), $this->dataTableUID, $UID);//TODO find a good way o make this work
            $privileges = array_keys($privilegesData);
            foreach ($privileges as $id)
            {
                if ($privilegesData[$id]['read'] == 0
                    && $data[$id]['data'] != '')
                {
                    $data[$id]['data'] = '[protected data]';
                }
                if ($privilegesData[$id]['write'] != 0)
                {
                    $data[$id]['isWritable'] = 1;
                }
            }
        }

        $this->cache[$cacheHash] = $data;

        return $data;
    }
}
