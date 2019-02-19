<?php

namespace RequestPortal\Data\Repositories\Dao;

use RequestPortal\Data\Repositories\Contracts\PortalUsersRepository;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;

class PortalUsersDao extends CachedDbDao implements PortalUsersRepository
{
    protected $tableName = "users";

    public function getAll()
    {
        return $this->getConn()->select();
    }

    public function getById($id)
    {
        return $this->getConn()->where('userID', $id)->first();
    }
}