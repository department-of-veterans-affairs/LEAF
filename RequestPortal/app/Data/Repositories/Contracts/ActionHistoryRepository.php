<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface ActionHistoryRepository
{
    public function insert($recordID, $empUID, $dependencyID, $actionType, $actionTypeID, $time, $comment, $stepID);
}