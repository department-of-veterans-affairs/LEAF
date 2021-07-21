<?php
// Include XSSHelpers
if (!class_exists('XSSHelpers'))
{
    include_once __DIR__ . '/../libs/php-commons/XSSHelpers.php';
}

include '../libs/smarty/Smarty.class.php';

function customTemplate($tpl)
{
    return file_exists("./templates/custom_override/{$tpl}") ? "custom_override/{$tpl}" : $tpl;
}

$returnPage = isset($_GET['return']) ? XSSHelpers::xscrub($_GET['return']) : './';

$main = new Smarty;
$main->assign('title', 'LEAF Session Expired');
$main->assign('leafSecure', 0);
$main->assign('revision', '');
$main->assign('previousPage', $returnPage);
$main->display(customTemplate('view_session_expire.tpl'));
