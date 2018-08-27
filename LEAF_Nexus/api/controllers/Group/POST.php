<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

$this->index['POST']->register('group', function ($args) use ($group) {
    $_POST['parentID'] = isset($_POST['parentID']) ? $_POST['parentID'] : 0;

    try
    {
        return $group->addNew($_POST['title'], $_POST['parentID']);
    }
    catch (Exception $e)
    {
        return $e->getMessage();
    }
});
$this->index['POST']->register('group/[digit]', function ($args) use ($group) {
    try
    {
        $group->modify($args[0]);
    }
    catch (Exception $e)
    {
        return $e->getMessage();
    }

    return true;
});
$this->index['POST']->register('group/[digit]/position', function ($args) use ($group) {
    return $group->addPosition($args[0], $_POST['positionID']);
});
$this->index['POST']->register('group/[digit]/employee', function ($args) use ($group) {
    return $group->addEmployee($args[0], $_POST['empUID']);
});
$this->index['POST']->register('group/[digit]/tag', function ($args) use ($group) {
    try
    {
        return $group->addTag((int)$args[0], $_POST['tag']);
    }
    catch (Exception $e)
    {
        return $e->getMessage();
    }
});
$this->index['POST']->register('group/[digit]/title', function ($args) use ($group) {
    $_POST['abbreviatedTitle'] = isset($_POST['abbreviatedTitle']) ? $_POST['abbreviatedTitle'] : '';

    try
    {
        $group->editTitle($args[0], $_POST['title'], $_POST['abbreviatedTitle']);
    }
    catch (Exception $e)
    {
        return $e->getMessage();
    }

    return true;
});

$this->index['POST']->register('group/[digit]/permissions/addEmployee', function ($args) use ($group) {
    $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

    return $group->addPermission($args[0], 'employee', $_POST['empUID'], $type);
});
$this->index['POST']->register('group/[digit]/permissions/addPosition', function ($args) use ($group) {
    $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

    return $group->addPermission($args[0], 'position', $_POST['positionID'], $type);
});
$this->index['POST']->register('group/[digit]/permissions/addGroup', function ($args) use ($group) {
    $type = isset($_POST['permission']) ? $_POST['permission'] : 'read';

    return $group->addPermission($args[0], 'group', $_POST['groupID'], $type);
});
$this->index['POST']->register('group/[digit]/permission/[text]/[digit]/[text]/toggle', function ($args) use ($group) {
    //$groupID, $categoryID, $UID, $permissionType
    return $group->togglePermission($args[0], $group->sanitizeInput($args[1]), $args[2], $args[3]);
});
