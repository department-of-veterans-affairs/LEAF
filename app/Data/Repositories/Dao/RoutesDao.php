<?php

namespace App\Data\Repositories\Dao;
use App\Data\Repositories\Contracts\RoutesRepository;
use Illuminate\Support\Facades\DB;

class RoutesDao implements RoutesRepository
{

    private function getConn()
    {
        return DB::connection('routes')->table('routes');
    }

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getByName($name)
    {
        return $this->getConn()->where('name', $name)->first();
    }
}