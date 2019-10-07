<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Nexus\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Nexus\Data\Repositories\Contracts\PositionsRepository;

class PositionsDao extends CachedDbDao implements PositionsRepository
{
    protected $connectionName = "nexus";
    protected $tableName = "positions";

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getById($id)
    {
        return $this->getConn()->where('positionID', $id)->first();
    }

    /**
     * Get position title
     * @param int $positionID
     * @return string position title / boolean false
     */
    public function getTitle($positionID)
    {
        if (!is_numeric($positionID))
        {
            return false;
        }
        $res = null;
        if (isset($this->cache["res_select_position_{$positionID}"]))
        {
            $res = $this->cache["res_select_position_{$positionID}"];
        }
        else
        {
            $res = $this->getConn()
            ->where('positionID', $positionID)
            ->get()
            ->toArray();
            $this->cache["res_select_position_{$positionID}"] = $res;
        }
        
        return isset($res[0]->positionTitle) ? $res[0]->positionTitle : false;
    }
}
