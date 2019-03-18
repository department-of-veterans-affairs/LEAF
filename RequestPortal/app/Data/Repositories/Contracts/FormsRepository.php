<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface FormsRepository
{
    public function createFormCount($recordID, $categoryID, $count);
    public function getById($formID);
    public function getCountById($formID);
    public function getStapledForms($categoryID);
}