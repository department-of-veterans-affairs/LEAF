<?php

namespace RequestPortal\Data\Repositories\Contracts;

interface FormsRepository
{
    public function createFormCount($recordId, $categoryId, $count);
    public function getById($formId);
    public function getCountById($formId);
    public function getStapledForms($categoryId);
}