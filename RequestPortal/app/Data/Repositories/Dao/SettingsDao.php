<?php

namespace RequestPortal\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;
use RequestPortal\Data\Repositories\Contracts\SettingsRepository;

class SettingsDao extends CachedDbDao implements SettingsRepository
{
    protected $tableName = "settings";

    private function getSetting($setting)
    {
        return $this->getConn()->select('data')->where('setting', $setting)->first();
    }

    public function getDbVersion()
    {
        return $this->getSetting('dbversion');
    }

    public function getHeading()
    {
        return $this->getSetting('heading');
    }

    public function getRequestLabel()
    {
        return $this->getSetting('requestLabel');
    }

    public function getSubHeading()
    {
        return $this->getSetting('subheading');
    }

    public function getTimeZone()
    {
        return $this->getSetting('timeZone');
    }

    public function getVersion()
    {
        return $this->getSetting('version');
    }
}