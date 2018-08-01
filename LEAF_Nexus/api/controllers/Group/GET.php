<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$this->index['GET']->register('group', function ($args) {
    return print_r($args, true) . print_r($_GET, true);
});
$this->index['GET']->register('group/list', function ($args) use ($group) {
    return $group->listGroups(0, $_GET['offset'], $_GET['quantity']);
});
$this->index['GET']->register('group/[digit]', function ($args) use ($group) {
    $groupID = (int)$args[0];
    $ret = $group->getAllData($groupID);
    $ret['title'] = $group->getTitle($groupID);

    return $ret;
});
$this->index['GET']->register('group/[digit]/summary', function ($args) use ($group) {
    return $group->getSummary($args[0]);
});
$this->index['GET']->register('group/[digit]/list', function ($args) use ($group) {
    return $group->listGroups($args[0], $_GET['offset'], $_GET['quantity']);
});
$this->index['GET']->register('group/[digit]/positions', function ($args) use ($group) {
    return $group->listGroupPositions($args[0]);
});
$this->index['GET']->register('group/[digit]/leader', function ($args) use ($group) {
    return $group->getGroupLeader($args[0]);
});
$this->index['GET']->register('group/[digit]/employees', function ($args) use ($group) {
    return $group->listGroupEmployees($args[0]);
});
$this->index['GET']->register('group/[digit]/employees/all', function ($args) use ($group) {
    return $group->listGroupEmployeesAll($args[0]);
});
$this->index['GET']->register('group/[digit]/employees/detailed', function ($args) use ($group) {
    $limit = -1;
    if (isset($_GET['limit']))
    {
        $limit = (int)$_GET['limit'];
    }

    $offset = 0;
    if (isset($_GET['offset']))
    {
        $offset = (int)$_GET['offset'];
    }

    return $group->listGroupEmployeesDetailed($args[0], $searchText, $offset, $limit);
});
$this->index['GET']->register('group/search', function ($args) use ($group) {
    if (isset($_GET['noLimit']) && $_GET['noLimit'] == 1)
    {
        $group->setNoLimit();
    }

    return $group->search($_GET['q'], $group->sanitizeInput($_GET['tag']));
});
$this->index['GET']->register('group/tag', function ($args) use ($group) {
    return $group->listGroupsByTag($group->sanitizeInput($_GET['tag']));
});
$this->index['GET']->register('group/tag/[text]', function ($args) use ($group) {
    return $group->listGroupsByTag($group->sanitizeInput($args[0]));
});
$this->index['GET']->register('group/[digit]/data/[digit]', function ($args) use ($group) {
    return $group->getAllData((int)$args[0], (int)$args[1]);
});
