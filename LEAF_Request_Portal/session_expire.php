<?php

use App\Leaf\XSSHelpers;

require_once '/var/www/html/app/libs/loaders/Leaf_autoloader.php';

function customTemplate(string $tpl = "view_about.tpl"): string
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
