<?php

namespace RequestPortal\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;
use RequestPortal\Data\Repositories\Contracts\ActionHistoryRepository;

class ActionHistoryDao extends CachedDbDao implements ActionHistoryRepository
{
    protected $tableName = "action_history";

    public function insert($recordID, $empUID, $dependencyID, $actionType, $actionTypeID, $time, $comment=null, $stepID = 0)
    {              
        $this->getConn()->insert([
            'recordID' => $recordID, 
            'empUID' => $empUID, 
            'dependencyID' => $dependencyID, 
            'actionType' => $actionType, 
            'actionTypeID' => $actionTypeID, 
            'time' => $time, 
            'comment' => $comment, 
            'stepID' => $stepID
        ]);
    }
}