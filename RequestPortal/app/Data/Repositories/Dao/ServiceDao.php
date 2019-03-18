<?php

namespace RequestPortal\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;
use RequestPortal\Data\Repositories\Contracts\ServiceRepository;

class ServiceDao extends CachedDbDao implements ServiceRepository
{
    protected $tableName = "services";

    public function getById($serviceID)
    {
        return $this->getConn()->where('serviceID', $serviceID)->first();
    }

    public function getByName($serviceName)
    {
        return $this->getConn()->where('service', $serviceName)->first();
    }
}