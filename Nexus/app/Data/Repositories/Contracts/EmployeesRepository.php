<?php

namespace Nexus\Data\Repositories\Contracts;

interface EmployeesRepository
{
    public function getAll();
    public function getById($id);
    public function getByUsername($username);
    public function lookupEmpUID($empUID);
}