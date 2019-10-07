<?php

namespace Nexus\Data\Repositories\Contracts;

interface GroupsRepository
{
    public function getAll();
    public function getById($id);
    public function getGroup($groupID);
}