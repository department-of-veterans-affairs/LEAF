<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

error_reporting(E_ALL & ~E_NOTICE);

include '../libs/smarty/Smarty.class.php';

// Include XSSHelpers
if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../libs/php-commons/XSSHelpers.php';
}

$action = isset($_GET['a']) ? XSSHelpers::xscrub($_GET['a']) : '';
$script = isset($_GET['s']) ? XSSHelpers::scrubFilename(XSSHelpers::xscrub($_GET['s'])) : '';

$main = new Smarty;
$main->left_delimiter = '{{';
$main->right_delimiter = '}}';

header('Content-type: application/javascript');
switch ($action) {
    case 'workflowStepModules':
        $stepID = (int)$_GET['stepID'];
        if ($script != ''
            && file_exists("scripts/workflowStepModules/{$script}.tpl")
            && $stepID > 0)
        {
            $main->assign('stepID', $stepID);
            $main->display("scripts/workflowStepModules/{$script}.tpl");
        }
        break;
    default:
        break;
}
