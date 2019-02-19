<?php

namespace Nexus\Data\Repositories\Contracts;

interface NexusUsersRepository
{
    public function getAll();
    public function getById($id);
    public function getByUsername($username);
}