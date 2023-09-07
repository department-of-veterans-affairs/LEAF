<?php

namespace App\Leaf\Logger;

class LogItem
{
    public $tableName;
    public $column;
    public $value;
    public $displayValue;

    public function __construct($tableName, $column, $value, $displayValue = null)
    {
        $this->tableName = $tableName;
        $this->column = $column;
        $this->value = $value;
        $this->displayValue = $displayValue;
    }
}
