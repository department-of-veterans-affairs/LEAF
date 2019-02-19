<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface RecordsRepository
{
    public function create($record);
    public function getAll();
    public function getById($recordId);
}