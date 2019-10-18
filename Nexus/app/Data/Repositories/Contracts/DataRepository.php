<?php

namespace Nexus\Data\Repositories\Contracts;

interface DataRepository
{
    public function getAllData($UID, $indicatorID);
}