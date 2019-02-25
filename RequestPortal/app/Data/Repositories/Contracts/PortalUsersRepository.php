<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface PortalUsersRepository
{
    public function getAll();
    public function getById($userID);
    public function isAdmin($userID);
    public function getEmpUID($userID);
    //public function getMembership($userID);
}