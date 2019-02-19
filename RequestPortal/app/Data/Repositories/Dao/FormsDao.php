<?php

namespace RequestPortal\Data\Repositories\Dao;

use RequestPortal\Data\Repositories\Contracts\FormsRepository;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;

class FormsDao extends CachedDbDao implements FormsRepository
{
    protected $tableName = "categories";

    public function createFormCount($recordId, $categoryId, $count)
    {
        return $this->getConnForTable('category_count')->insertGetId([
            'recordID' => $recordId,
            'categoryID' => $categoryId,
            'count' => $count
        ]);
    }

    public function getCountById($formId)
    {
        return $this->getConn()->where('categoryID', $formId)->count();
    }

    public function getById($formId)
    {
        return $this->getConn()->where('categoryID', $formId)->first();
        
    }

    public function getStapledForms($categoryId)
    {
        return $this->getConnForTable('category_staples')->where('categoryID', $categoryId)->get();
    }
}