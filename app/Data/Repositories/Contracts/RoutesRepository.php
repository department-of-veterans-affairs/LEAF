<?php

namespace App\Data\Repositories\Contracts;

interface RoutesRepository
{
    public function getAll();
    public function getByName($name);
}