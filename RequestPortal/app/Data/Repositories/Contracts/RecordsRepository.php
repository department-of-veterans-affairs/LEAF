<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Data\Repositories\Contracts;

interface RecordsRepository
{
    public function create($record);

    public function getAll();

    public function getById($recordID);

    public function delete($recordID);

    public function restore($recordID);

    public function isNeedToKnow($recordID = null);

    public function getForm($recordID);

    public function getFormJSON($recordID);

    public function addTag($recordID, $tag, $empUID);
}
