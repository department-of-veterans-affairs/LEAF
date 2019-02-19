<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface ServiceRepository {
    public function getById($serviceId);
    public function getByName($serviceName);
}