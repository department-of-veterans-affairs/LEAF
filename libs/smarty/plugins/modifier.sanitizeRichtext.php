<?php
/**
 * Smarty plugin
 *
 * @package    Smarty
 * @subpackage PluginsModifier
 */

/**
 * Smarty HTML sanitation modifier plugin
 * Type:     modifier<br>
 * Name:     sanitize<br>
 * Purpose:  Simple HTML sanitation, allows some tags for use in rich text editors. 
 * 
 * Allowed tags: <a><b><i><u><ol><li><br><p><table><td><tr><a><span><strong><em>
 *  
 * 
 * @author Nathan Sullivan
 *
 * @param string $in    input string
 *
 * @return string
 */
if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../php-commons/XSSHelpers.php';
}
function smarty_modifier_sanitizeRichtext($in)
{
    return XSSHelpers::sanitizeHTMLRich($in);
}
