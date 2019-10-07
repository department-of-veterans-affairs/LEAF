<?php

namespace Nexus\Data\Repositories\Contracts;

interface PositionsRepository
{
    public function getAll();
    public function getById($id);
    public function getTitle($positionID);
}