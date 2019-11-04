<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Data\Repositories\Dao;

use App\Data\Repositories\Dao\CachedDbDao;
use RequestPortal\Data\Model\Record;
use RequestPortal\Data\Repositories\Contracts\RecordsRepository;
use RequestPortal\Data\Repositories\Contracts\PortalUsersRepository;

class RecordsDao extends CachedDbDao implements RecordsRepository
{
    protected $tableName = 'records';

    protected $cache = array();

    /**
     * Protal Users Repository
     *
     * @var PortalUsersRepository
     */
    protected $portalUsers;

    /**
     * Create a new Record
     *
     * @var Record
     */
    public function create($record)
    {
        if ($record instanceof Record)
        {
            return $this->getConn()->insertGetId(array(
                'date' => $record->date,
                'serviceID' => $record->serviceID,
                'empUID' => $record->empUID,
                'title' => $record->title,
                'priority' => $record->priority,
            ));
        }
    }

    public function getAll()
    {
        return $this->getConn()->get();
    }

    public function getById($recordID)
    {
        return $this->getConn()->where('recordID', $recordID)->get();
    }

    public function delete($recordID)
    {
        return $this->getConn()->where('recordID', $recordID)->update(array('deleted' => time()));
    }

    public function restore($recordID)
    {
        return $this->getConn()->where('recordID', $recordID)->update(array('deleted' => 0));
    }

    /**
     * Check if need to know mode is enabled for any form, or a specific form
     * @param int $recordID
     * @return boolean
     */
    public function isNeedToKnow($recordID = null)
    {
        if (isset($this->cache['isNeedToKnow_' . $recordID]))
        {
            return $this->cache['isNeedToKnow_' . $recordID];
        }
        if ($recordID == null)
        {
            $res = $this->getConnForTable('categories')
            ->where('needToKnow', 1)
            ->get();
            if (count($res) == 0)
            {
                $this->cache['isNeedToKnow_' . $recordID] = false;

                return false;
            }
        }
        else
        {
            $res = $this->getConnForTable('category_count')
            ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
            ->where([['recordID', $recordID],['needToKnow', 1],['count', '>', 0]])
            ->get();

            if (count($res) == 0)
            {
                $this->cache['isNeedToKnow_' . $recordID] = false;

                return false;
            }
        }

        $this->cache['isNeedToKnow_' . $recordID] = true;

        return true;
    }

    public function getForm($recordID, $limitCategory = null)
    {
        $jsonRootIdx = -1;

        $json['label'] = 'name';
        $json['identifier'] = 'jsonIdx';

        if ($limitCategory == null)
        {
            // pull category counts
            $res2 = $this->getConnForTable('category_count')
                ->leftJoin('categories', 'category_count.categoryID', '=', 'categories.categoryID')
                ->where([['recordID', $recordID],['count', '>', 0]])
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
        }
        else
        {
            $res2 = $this->getConnForTable('categories')
                ->where('categoryID', $limitCategory)
                ->get()
                ->toArray();
            $res2[0]['count'] = 1;
        }

        foreach ($res2 as $catType)
        {
            $catType = (array) $catType;
            for ($i = 1; $i <= $catType['count']; $i++)
            {
                $tmp['name'] = $catType['count'] > 1
                                    ? $catType['categoryName'] . ' #' . $i
                                    : $catType['categoryName'];
                $tmp['type'] = 'form';
                $tmp['jsonIdx'] = --$jsonRootIdx;
                $tmp['series'] = $i;
                $tmp['children'] = $this->buildFormJSONStructure($catType['categoryID'], $i);
                $json['items'][] = $tmp;
            }
        }

        return $json;
    }

    public function buildFormJSONStructure($categoryID, $series = 1)
    {
        $categoryID = ($categoryID == null) ? 'general' : $categoryID;

        if (!isset($this->cache["categoryID{$categoryID}_indicators"]))
        {
            $res = $this->getConnForTable('indicators')
                ->where([['categoryID', $categoryID],['disabled', 0]])
                ->wherenull('parentID')
                ->orderBy('sort', 'asc')
                ->get()
                ->toArray();
            
            $this->cache["categoryID{$categoryID}_indicators"] = $res;
        }
        else
        {
            $res = $this->cache["categoryID{$categoryID}_indicators"];
        }

        $indicators = array();
        $counter = 1;
        foreach ($res as $ind)
        {
            $ind = (array) $ind;
            $desc = $ind['description'] != '' ? $ind['description'] : $ind['name'];
            $indicator['name'] = "$series.$counter: " . strip_tags($desc);
            $indicator['desc'] = strip_tags($desc);
            $indicator['type'] = $categoryID;
            $indicator['jsonIdx'] = $ind['indicatorID'] . '.' . $series;
            $indicator['series'] = $series;
            $indicator['format'] = $ind['format'];
            $indicator['indicatorID'] = $ind['indicatorID'];
            $indicators[] = $indicator;
            $counter++;
        }

        return $indicators;
    }

    public function getFormJSON($recordID)
    {
        $json = $this->getForm($recordID);

        return json_encode($json);
    }

    public function addToCategoryCount($recordID, $categoryID)
    {
        $res = $this->getConnForTable('category_count')
            ->updateOrInsert(['recordID' => $recordID, 'categoryID' => $categoryID], ['count' => 1]);
    }

    public function switchCategoryCount($recordID)
    {
        $this->getConnForTable('category_count')
            ->where('recordID', $recordID)
            ->update(['count' => 0]);

        return 1;
    }

    public function addTag($recordID, $tag, $empUID)
    {
        $res = $this->getConnForTable('tags')
        ->updateOrInsert(['recordID' => $recordID, 'tag' => $tag, 'empUID' => $empUID], ['timestamp' => time()]);
    }

    public function deleteTag($recordID, $tag, $empUID)
    {
        $res = $this->getConnForTable('tags')
        ->where(['recordID' => $recordID, 'tag' => $tag, 'empUID' => $empUID])
        ->delete();
    }

    public function getIndicator($indicatorID)
    {
        $res = $this->getConnForTable('indicators')
            ->where(['indicatorID' => $indicatorID, 'disabled' => 0])
            ->get()
            ->toArray();
        
        return $res;
    }

    public function getIndicatorData($indicatorID, $series, $recordID)
    {
        $res = $this->getConnForTable('data')
        ->select('data.*', 'indicator_mask.groupID', 'indicators.*')
        ->leftJoin('indicators', 'indicators.indicatorID', '=', 'data.indicatorID')
        ->leftJoin('indicator_mask', function($join)
        {
            $join->on('indicator_mask.indicatorID', '=', 'indicators.indicatorID');
            $join->on('indicator_mask.indicatorID','=','data.indicatorID');
            $join->on('data.indicatorID','=','indicators.indicatorID');
        })
        ->where(['data.indicatorID' => $indicatorID, 'series' => $series, 'recordID' => $recordID, 'disabled' => 0])
        ->get()
        ->toArray();

        if (!isset($res[0]))
        {
            $res = $this->getIndicator($indicatorID);
        }
        
        return $res;
    }

    public function getDataForIndicatorArray($indicatorArray, $series, $recordID)
    {
        return $this->getConnForTable('data')
        ->select('data', 'timestamp', 'data.indicatorID', 'groupID')
        ->leftJoin('indicator_mask', 'indicator_mask.indicatorID', '=', 'data.indicatorID')
        ->whereIn('data.indicatorID', $indicatorArray)
        ->where(['series' => $series, 'recordID' => $recordID])
        ->get()
        ->toArray();
    }

    public function getCategoryCount($recordID)
    {
        $res = $this->getConnForTable('category_count')
        ->where(['recordID' => $recordID])
        ->groupBy('categoryID')
        ->get()
        ->toArray();

        return $res;
    }

    public function getIsWritable($recordID)
    {
        return $this->getConn()
        ->select('empUID', 'isWritableUser', 'isWritableGroup')
        ->where('recordID', $recordID)
        ->get()
        ->toArray();
    }

    public function getCategoryPrivs($categoryID, $empUID)
    {
        return $this->getConnForTable('category_privs')
        ->leftJoin('users', 'users.groupID', '=', 'category_privs.groupID')
        ->where(['categoryID' => $categoryID, 'empUID' => $empUID, 'writable' => 1])
        ->get()
        ->toArray();
    }

    public function getRecordPrivs($recordID)
    {
        return $this->getConnForTable('records_workflow_state')
        ->select('recordID', 'groupID', 'dependencyID', 'records.empUID', 'serviceID', 'indicatorID_for_assigned_empUID', 'indicatorID_for_assigned_groupID')
        ->leftJoin('step_dependencies', 'step_dependencies.stepID', '=', 'records_workflow_state.stepID')
        ->leftJoin('workflow_steps', 'workflow_steps.stepID', '=', 'records_workflow_state.stepID')
        ->leftJoin('dependency_privs', 'dependency_privs.dependencyID', '=', 'records_workflow_state.dependencyID')
        ->leftJoin('users', 'users.groupID', '=', 'records_workflow_state.groupID')
        ->leftJoin('records', 'records.recordID', '=', 'records_workflow_state.recordID')
        ->where(['recordID' => $recordID])
        ->get()
        ->toArray();
    }

    public function getRecordIDFromRecord($recordID)
    {
        return $this->getConn()
        ->select('userID')
        ->where(['recordID' => $recordID])
        ->get()
        ->toArray();
    }

    public function getIndicatorMask($indicatorID)
    {
        return $this->getConnForTable('indicator_mask')
        ->where(['indicatorID' => $indicatorID])
        ->get()
        ->toArray();
    }

    public function getIndicatorsByParent($parentID)
    {
        return $this->getConnForTable('indicators')
        ->where(['parentID' => $parentID, 'disabled' => 0])
        ->orderBy('sort', 'asc')
        ->get()
        ->toArray();
    }

    public function updateInitiator($recordID, $empUID)
    {
        return $this->getConn()->where('recordID', $recordID)->update(array('empUID' => $empUID));                                        
    }

    public function getCountAndSubmitStatus($recordID)
    {
        return $this->getConn()
        ->select('records.recordID', 'categoryID', 'count', 'submitted')
        ->leftJoin('category_count', 'category_count.recordID', '=', 'records.recordID')
        ->where(['records.recordID' => $recordID])
        ->get()
        ->toArray();
    }

    public function getIndicatorCompletedCount($recordID)
    {
        return $this->getConnForTable('data')
        ->selectraw('COUNT(*)')
        ->leftJoin('indicators', 'indicators.indicatorID', '=', 'data.indicatorID')
        ->where(['recordID' => $recordID, 'indicators.required' => 1, 'indicators.disabled' => 0])
        ->where('data', '!=' , "")
        ->get()
        ->toArray();
    }

    public function getIndicatorTotalCount()
    {
        return $this->getConnForTable('indicators')
        ->selectraw('categoryID, COUNT(*)')
        ->where(['required' => 1, 'disabled' => 0])
        ->groupBy('categoryID')
        ->get()
        ->toArray();
    }

    public function getSteps($recordID)
    {
        return $this->getConnForTable('records_workflow_state')
        ->select('dependencies.dependencyID', 'records.recordID', 'workflow_steps.stepID', 'stepTitle', 'blockingStepID', 'workflowID', 'serviceID', 'stepBgColor', 'stepFontColor', 'stepBorder', 'description', 'indicatorID_for_assigned_empUID', 'indicatorID_for_assigned_groupID', 'jsSrc', 'empUID', 'requiresDigitalSignature')
        ->leftJoin('records', 'records.recordID', '=', 'records_workflow_state.recordID')
        ->leftJoin('workflow_steps', 'workflow_steps.stepID', '=', 'records_workflow_state.stepID')
        ->leftJoin('step_dependencies', 'step_dependencies.stepID', '=', 'records_workflow_state.stepID')
        ->leftJoin('dependencies', 'dependencies.dependencyID', '=', 'step_dependencies.dependencyID')
        ->leftJoin('records_dependencies', function($join)
                                            {
                                                $join->on('records_dependencies.recordID', '=', 'records.recordID');
                                                $join->on('records_dependencies.dependencyID','=','dependencies.dependencyID');
                                            })
        ->where(['records.recordID' => $recordID])
        ->get()
        ->toArray();
    }

    public function getDependencyActions($workflowID, $stepID){           
        return $this->getConnForTable('workflow_routes')
        ->leftJoin('actions', 'actions.actionType', '=', 'workflow_routes.actionType')
        ->where(['workflowID' => $workflowID, 'stepID' => $stepID])
        ->orderBy('sort', 'asc')
        ->get()
        ->toArray();
    }

    public function getDependencyPrivs($dependencyID)
    {
        return $this->getConnForTable('dependency_privs')
        ->where(['dependencyID' => $dependencyID])
        ->get()
        ->toArray();
    }

    public function getServicesForQuads($quadGroupIDs, $serviceID)
    {
        return $this->getConnForTable('services')
        ->where(['groupID' => $quadGroupIDs, 'serviceID' => $serviceID])
        ->get()
        ->toArray();
    }

    public function getGroup($groupID)
    {
        return $this->getConnForTable('groups')
        ->where(['groupID' => $groupID])
        ->get()
        ->toArray();
    }

    public function getStepModules($stepID)
    {
        return $this->getConnForTable('step_modules')
        ->select('moduleName', 'moduleConfig')
        ->where(['stepID' => $stepID])
        ->get()
        ->toArray();
    }

    public function SubmitIfNotSubmitted($recordID)
    {
        $res = $this->getConn()
        ->where(['recordID' => $recordID])
        ->get()
        ->toArray();
        if ($res[0]['submitted'] == 0)
        {
            $this->getConn()
            ->where(['recordID' => $recordID])
            ->update(['submitted' => time()]);
        }   
    }

    public function getStep($stepID)
    {
        return $this->getConnForTable('workflow_steps')
        ->where(['stepID' => $stepID])
        ->get()
        ->toArray();
    }

    private function resetRecordsDependency($recordID, $stepID)
    {
        $res3 = $this->getConnForTable('step_dependencies')
        ->where(['stepID' => $stepID])
        ->get()
        ->toArray();
        if (count($res3) > 0)
        {
            foreach ($res3 as $stepDependency)
            {
                $this->getConnForTable('records_dependencies')
                ->where(['recordID' => $recordID, 'dependencyID' => $stepDependency['dependencyID']])
                ->update(['filled' => 0]);
            }
        }
    }

    public function writeStepChangeLogEntry($recordID, $stepID, $empUID, $comment)
    {
        $this->getConnForTable('action_history')
        ->insert(['recordID' => $recordID, 'empUID' => $empUID, 'dependencyID' => 0, 'actionType' => 'move', 'actionTypeID' => 8, 'time' => time(), 'comment' => $comment]);

        $this->getConnForTable('records_workflow_state')
        ->where(['recordID' => $recordID])
        ->delete();

        $this->resetRecordsDependency($recordID, $stepID);

        $this->getConnForTable('records_workflow_state')
        ->insert(['recordID' => $recordID, 'stepID' => $stepID]);
    
    }
}
