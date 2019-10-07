<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Nexus\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Nexus\Data\Repositories\Contracts\GroupsRepository;

class GroupsDao extends CachedDbDao implements GroupsRepository
{
    protected $connectionName = "nexus";
    protected $tableName = "groups";

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getById($id)
    {
        return $this->getConn()->where('groupID', $id)->first();
    }

    public function getGroup($groupID)
    {
        if (isset($this->cache["getGroup_{$groupID}"]))
        {
            return $this->cache["getGroup_{$groupID}"];
        }
        $res = $this->getConn()
        ->where('groupID', $groupID)
        ->get()
        ->toArray();
        $this->cache["getGroup_{$groupID}"] = $res;

        return $res;
    }
}
