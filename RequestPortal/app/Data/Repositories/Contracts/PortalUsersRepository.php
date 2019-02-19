<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface PortalUsersRepository
{
    public function getAll();
    public function getById($id);
}