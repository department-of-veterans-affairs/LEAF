<?php

namespace RequestPortal\Data\Repositories\Dao;

use RequestPortal\Data\Repositories\Contracts\FormsRepository;
use App\Data\Repositories\Dao\CachedDbDao;
use Illuminate\Support\Facades\DB;

class FormsDao extends CachedDbDao implements FormsRepository
{
    protected $tableName = "categories";

    public function createFormCount($recordID, $categoryID, $count)
    {
        return $this->getConnForTable('category_count')->insertGetId([
            'recordID' => $recordID,
            'categoryID' => $categoryID,
            'count' => $count
        ]);
    }

    public function getCountById($formID)
    {
        return $this->getConn()->where('categoryID', $formID)->count();
    }

    public function getById($formID)
    {
        return $this->getConn()->where('categoryID', $formID)->first();
        
    }

    public function getStapledForms($categoryID)
    {
        return $this->getConnForTable('category_staples')->where('categoryID', $categoryID)->get();
    }

    public function getAllForms()
    {
        return $this->getConnForTable('categories')
        ->select('categoryID', 'categoryName', 'categoryDescription')
        ->where('disabled', 0)
        ->get();
    }
}