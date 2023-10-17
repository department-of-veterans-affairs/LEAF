<?php
/**
 * Smarty plugin
 *
 * @package    Smarty
 * @subpackage PluginsModifier
 */

use Leaf\XSSHelpers;

/**
 * Smarty HTML sanitation modifier plugin
 * Type:     modifier<br>
 * Name:     sanitize<br>
 * Purpose:  Simple HTML sanitation, allows some tags for use in rich text editors.
 *
 * Allowed tags: <a><b><i><u><ol><li><br><p><table><td><tr>
 *
 *
 * @author Nathan Sullivan
 *
 * @param string $in    input string
 *
 * @return string
 */
if(!class_exists('Leaf\XSSHelpers')){
    include_once __DIR__ . '/../../php-commons/XSSHelpers.php';
}

function smarty_modifier_sanitize($in)
{
    return XSSHelpers::sanitizeHTML($in);
}