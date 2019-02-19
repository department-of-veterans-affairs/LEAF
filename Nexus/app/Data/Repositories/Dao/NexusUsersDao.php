<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Nexus\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Nexus\Data\Repositories\Contracts\NexusUsersRepository;

class NexusUsersDao extends CachedDbDao implements NexusUsersRepository
{
    protected $connectionName = "nexus";
    protected $tableName = "employee";

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getById($id)
    {
        return $this->getConn()->where('empUID', $id)->first();
    }

    public function getByUsername($username)
    {
        return $this->getConn()->where([
                ['userName', $username], 
                ['deleted', 0]
            ])->first();
    }
}
