<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface ServiceRepository {
    public function getById($serviceID);
    public function getByName($serviceName);
}