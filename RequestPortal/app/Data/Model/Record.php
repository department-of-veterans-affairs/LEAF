<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace RequestPortal\Data\Model;

class Record
{
    public $recordID;

    public $date;

    public $serviceID;

    public $userID;

    public $title;

    public $priority;

    public $lastStatus;

    public $submitted;

    public $deleted;

    public $isWritableUser;

    public $isWritableGroup;

    public function __construct(
        $date,
        $serviceID,
        $userID,
        $title,
        $priority = 0,
        $recordID = null,
        $lastStatus = null,
        $submitted = 0,
        $deleted = 0,
        $isWritableUser = 1,
        $isWritableGroup = 1
    ) {
        $this->recordID = $recordID;
        $this->date = $date;
        $this->serviceID = $serviceID;
        $this->userID = $userID;
        $this->title = $title;
        $this->priority = $priority;
        $this->lastStatus = $lastStatus;
        $this->submitted = $submitted;
        $this->deleted = $deleted;
        $this->isWritableUser = $isWritableUser;
        $this->isWritableGroup = $isWritableGroup;
    }

    public static function blank()
    {
        return self(time(), 0, null, null);
    }
}
