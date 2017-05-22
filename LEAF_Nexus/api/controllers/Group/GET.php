<?php

$this->index['GET']->register('group', function($args) {
    return print_r($args, true) . print_r($_GET, true);
});
$this->index['GET']->register('group/list', function($args) use ($group) {
    return $group->listGroups(0, $_GET['offset'], $_GET['quantity']);
});
$this->index['GET']->register('group/[digit]', function($args) use ($group) {
    $ret = $group->getAllData($args[0]);
    $ret['title'] = $group->getTitle($args[0]);
    return $ret;
});
$this->index['GET']->register('group/[digit]/summary', function($args) use ($group) {
    return $group->getSummary($args[0]);
});
$this->index['GET']->register('group/[digit]/list', function($args) use ($group) {
    return $group->listGroups($args[0], $_GET['offset'], $_GET['quantity']);
});
$this->index['GET']->register('group/[digit]/positions', function($args) use ($group) {
    return $group->listGroupPositions($args[0]);
});
$this->index['GET']->register('group/[digit]/leader', function($args) use ($group) {
	return $group->getGroupLeader($args[0]);
});
$this->index['GET']->register('group/[digit]/employees', function($args) use ($group) {
    return $group->listGroupEmployees($args[0]);
});
$this->index['GET']->register('group/[digit]/employees/all', function($args) use ($group) {
	return $group->listGroupEmployeesAll($args[0]);
});
$this->index['GET']->register('group/search', function($args) use ($group) {
	if(isset($_GET['noLimit']) && $_GET['noLimit'] == 1) {
		$group->setNoLimit();
	}
    return $group->search($_GET['q'], $_GET['tag']);
});
$this->index['GET']->register('group/tag', function($args) use ($group) {
    return $group->listGroupsByTag($_GET['tag']);
});
$this->index['GET']->register('group/tag/[text]', function($args) use ($group) {
	return $group->listGroupsByTag($args[0]);
});
$this->index['GET']->register('group/[digit]/data/[digit]', function($args) use ($group) {
    return $group->getAllData($args[0], $args[1]);
});
