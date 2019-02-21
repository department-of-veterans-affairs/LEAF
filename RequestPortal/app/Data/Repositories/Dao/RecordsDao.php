<?php

namespace RequestPortal\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;
use RequestPortal\Data\Model\Record;
use RequestPortal\Data\Repositories\Contracts\RecordsRepository;

class RecordsDao extends CachedDbDao implements RecordsRepository
{
    protected $tableName = "records";

    /**
     * Create a new Record
     *
     * @var Record
     */
    public function create($record)
    {
        if ($record instanceof Record) {
            return $this->getConn()->insertGetId([
                'date' => $record->date,
                'serviceID' => $record->serviceID,
                'userID' => $record->userID,
                'title' => $record->title,
                'priority' => $record->priority
            ]);
        } else {
            return null;
        }
    }

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getById($recordId)
    {
        return $this->getConn()->where('recordID', $recordId)->get();
    }

    public function delete($recordId)
    {
        return $this->getConn()->where('recordID', $recordId)->update(['deleted' => time()]);
    }
}
