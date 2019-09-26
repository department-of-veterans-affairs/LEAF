<?php

namespace App\Data\Repositories\Dao;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use App\Http\Middleware\GetDatabaseName;

class CachedDbDao
{
    /**
     * The name of the database table this DAO accesses.
     * This should be overridden in any class that extends this one. 
     */
    protected $tableName;

    /**
     * The database connection name, whether it is for a Request 
     * Portal ('portal'), or a Nexus ('nexus'). 
     * 
     * The default value is 'portal'. This can be overridden if any other 
     * connection is desired.
     */
    protected $connectionName = "portal";

    protected function getDbName()
    {
        $dbCacheUUID = "";
        switch ($this->connectionName)
        {
            case "nexus":
                $dbCacheUUID = session(GetDatabaseName::$req_cache_key_nexus);
                break;

            default: // 'portal' or anything else
                $dbCacheUUID = session(GetDatabaseName::$req_cache_key_request_portal);
                break;
        }

        return Cache::get($dbCacheUUID);
    }

    /**
     * Get a \Illuminate\Support\Facades\DB object set to use $tableName
     */
    protected function getConn()
    {
        return DB::table($this->getDbName() . "." . $this->tableName);
    }

    /**
     * Get a \Illuminate\Support\Facades\DB object set to use $tableName.
     * Use this when a different table than the one defined by the class variable $tableName
     */
    protected function getConnForTable($otherTable)
    {
        return DB::table($this->getDbName() . "." . $otherTable);
    }

    /**
     * Get a \Illuminate\Support\Facades\DB object set to use $tableName.
     * Use this when a different table than the one defined by the class variable $tableName
     */
    protected function getRawSQL()
    {
        return DB::getQueryLog();
    }

    /**
     * Get a \Illuminate\Support\Facades\DB object set to use $tableName.
     * Use this when a different table than the one defined by the class variable $tableName
     */
    protected function enableQueryLog()
    {
        DB::enableQueryLog();
    }
}