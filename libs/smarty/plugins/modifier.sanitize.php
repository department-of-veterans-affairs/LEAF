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
 * Allowed tags: <a><b><i><u><ol><li><br><p><table><td><tr>
 *
 *
 * @author Nathan Sullivan
 *
 * @param string $in    input string
 *
 * @return string
 */

 include_once __DIR__.'/../../loaders/Leaf_autoloader.php';

function smarty_modifier_sanitize($in)
{
    return Leaf\XSSHelpers::sanitizeHTML($in);
}