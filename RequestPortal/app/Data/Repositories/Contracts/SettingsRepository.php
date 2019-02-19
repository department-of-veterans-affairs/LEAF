<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface SettingsRepository
{
    public function getDbVersion();
    public function getHeading();
    public function getRequestLabel();
    public function getSubHeading();
    public function getTimeZone();
    public function getVersion();
}