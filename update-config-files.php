#!/usr/local/bin/php
<?php
define('VAR_NAME', 0); //var name
define('VAR_VALUE', 1); //var value
define('VAR_COMMENT', 2); //var comment
define('VAR_TYPE', 3); // static or const
define('NEW_LINE', "\n"); // new line
define('TAB', "\t \t "); // Tab
define('WORD_WRAP', 120); // word wrap

/**
 * [(php update-config-files.php -help) rertuns help]
 * [(php update-config-files.php write-portal) writes all Portal db-configs in a dir]
 * [(php update-config-files.php write-nexus) writes all Nexus configs in a dir]
 */
for ($i = 0; $i <= $argc -1; ++$i) {
    switch ($argv[$i]) {
    case '-help':
      print "Note: Before running this file edit the array for add/remove of variables \n1. (write-portal) Writes Portal Config \n2. (write-nexus) Writes Nexus Config \n";
    break;
    case 'write-portal':
      writePortalConfig();
    break;

    case 'write-nexus':
      writeNexusConfig();
    break;

    default:
      break;
  }
}

  /**
   * [writePortalConfig writes/backup all Portal db-configs in a root dir]
   * To add a variable to the db-config files add it to the array or to remove a variable remove it from the array
   * Note: if no value is supplied for a variable it will use the one in config file if exists
   * @return [string] [config content]
   */
    function writePortalConfig()
    {
        $portalConfig = array(
          'dbHost' => array('varName' => 'dbHost', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'dbName' => array('varName' => 'dbName', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'dbUser' => array('varName' => 'dbUser', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'dbPass' => array('varName' => 'dbPass', 'varValue' => '', 'varComment' => '', 'varType' => ''),

          'title' => array('varName' => 'title', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'city' => array('varName' => 'city', 'varValue' => '', 'varComment' => ''),
          'adminLogonName' => array('varName' => 'adminLogonName', 'varValue' => '', 'varComment' => 'Administrator\'s logon name', 'varType' => ''),
          'adPath' => array('varName' => 'adPath', 'varValue' => '', 'varComment' => 'Active directory path', 'varType' => ''),
          'uploadDir' => array('varName' => 'uploadDir', 'varValue' => '', 'varComment' => 'Directory for user uploads. using backslashes (/), with trailing slash', 'varType' => ''),
          'leafSecure' => array('varName' => 'leafSecure', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'orgchartPath' => array('varName' => 'orgchartPath', 'varValue' => "", 'varComment' => 'HTTP Path to orgchart with no trailing slash', 'varType' => ''),
          'orgchartImportTags' => array('varName' => 'orgchartImportTags', 'varValue' => "array('')", 'varComment' => 'Import org chart groups if they match these tags', 'varType' => ''),
          'descriptionID' => array('varName' => 'descriptionID', 'varValue' => '', 'varComment' => 'indicator ID for description field', 'varType' => ''),
          'emailPrefix' => array('varName' => 'emailPrefix', 'varValue' => '', 'varComment' => 'Email prefix', 'varType' => ''),
          'emailCC' => array('varName' => 'emailCC', 'varValue' => '', 'varComment' => 'CCed for every email', 'varType' => ''),
          'emailBCC' => array('varName' => 'emailBCC', 'varValue' => '', 'varComment' => 'BCCed for every email', 'varType' => ''),
          'phonedbHost' => array('varName' => 'phonedbHost', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'phonedbName' => array('varName' => 'phonedbName', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'phonedbUser' => array('varName' => 'phonedbUser', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'phonedbPass' => array('varName' => 'phonedbPass', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'myNewVar' => array('varName' => 'myNewVar', 'varValue' => "'myNewValue'", 'varComment' => 'my new comment', 'varType' => 'static'),
        );
        $portalConfigs = rGlob('./*config.php');
        foreach ($portalConfigs as $config) {
            if (preg_match("/\/LEAF_Request_Portal\/\w.*/", $config)) {
                //make a backup first
                $date = new Datetime();
                $timestamp = $date->format('U');
                $backupConfig = dirname($config) . '/' . basename($config) .  '.' . $timestamp . '.php';
                copy($config, $backupConfig);

                $file = file_get_contents($config);
                $varArray = parseStr($file);
                $vars = array_intersect_key(array_merge_recursive($portalConfig, $varArray), $portalConfig);
                $savedConfig = savePortal($config, $vars);
                //print_r($savedConfig);
            }
        }
    }

    /**
     * [writeNexusConfig writes/backup all Nexus configs in a root dir]
     * To add a variable to the config files add it to the array or to remove a variable remove it from the array
     * Note: if no value is supplied for a variable it will use the one in config file if exists
     * @return [string] [config content]
     */
    function writeNexusConfig()
    {
        $nexusConfig = array(
          'title' => array('varName' => 'title', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'city' => array('varName' => 'city', 'varValue' => '', 'varComment' => ''),
          'adminLogonName' => array('varName' => 'adminLogonName', 'varValue' => '', 'varComment' => 'Administrator\'s logon name', 'varType' => ''),
          'adPath' => array('varName' => 'adPath', 'varValue' => '', 'varComment' => 'Active directory paths', 'varType' => ''),
          'uploadDir' => array('varName' => 'uploadDir', 'varValue' => '', 'varComment' => 'Directory for user uploads. using backslashes (/), with trailing slash', 'varType' => ''),
          'ERM_Sites' => array('varName' => 'ERM_Sites', 'varValue' => "array('')", 'varComment' => 'URL to ERM sites with trailing slash', 'varType' => ''),
          'leafSecure' => array('varName' => 'leafSecure', 'varValue' => 'false', 'varComment' => 'leafSecure', 'varType' => ''),
          'dbHost' => array('varName' => 'dbHost', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'dbName' => array('varName' => 'dbName', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'dbUser' => array('varName' => 'dbUser', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'dbPass' => array('varName' => 'dbPass', 'varValue' => '', 'varComment' => '', 'varType' => ''),
          'myNewVar' => array('varName' => 'myNewVar', 'varValue' => "'myNewValue'", 'varComment' => 'my new comment', 'varType' => 'static'),
        );

        $nexusConfigs = rGlob('./config.php');
        foreach ($nexusConfigs as $config) {
            if (preg_match("/\/LEAF_Nexus\/\w.*/", $config)) {
                //make a backup first
                $date = new Datetime();
                $timestamp = $date->format('U');
                $backupConfig = dirname($config) . '/' . basename($config) .  '.' . $timestamp . '.php';
                copy($config, $backupConfig);

                $file = file_get_contents($config);
                $varArray = parseStr($file);
                $vars = array_intersect_key(array_merge_recursive($nexusConfig, $varArray), $nexusConfig);
                $savedConfig = saveNexus($config, $vars);
                //print_r($savedConfig);
            }
        }
    }

    /**
     * [rGlob searches directories]
     * @param  [string]  $pattern [the path to scan]
     * @param  integer $flags  [the flags passed to glob()]
     * @return [mixed]  [an array of files in the given path matching the pattern]
     */
    function rGlob($pattern, $flags = 0)
    {
        $files = glob($pattern, $flags);
        foreach (glob(dirname($pattern).'/*', GLOB_ONLYDIR|GLOB_NOSORT) as $dir) {
            $files = array_merge($files, rglob($dir.'/'.basename($pattern), $flags));
        }
        return $files;
    }

    /**
     * [parseStr parses all the tokens using token_get_all()]
     * @param  [string] $src [config files]
     * @return [mixed]  [an array of variables]
     */
    function parseStr($src)
    {
        $tokens = token_get_all($src);
        $current_var = array(VAR_NAME => false,
                            VAR_VALUE => false,
                            VAR_COMMENT => '',
                            VAR_TYPE => false);
        $vars = array();

        foreach ($tokens as $token) {
            // Most of the tokens are arrays: [0] => type, [1] => value
            if (is_array($token)) {
                $t_type = $token[0];
                $t_val = $token[1];
                if ($t_type == T_VARIABLE) {
                    if ($current_var[VAR_NAME] === false) {
                        $current_var[VAR_NAME] = substr($t_val, 1);
                    } elseif ($current_var[VAR_VALUE] !== false) {
                        $current_var[VAR_VALUE] .= $t_val;
                    }
                } elseif ($t_val === 'static') {
                    if ($current_var[VAR_TYPE] === false) {
                        $current_var[VAR_TYPE] = '';
                    } else {
                        $current_var[VAR_TYPE] .= $t_val;
                    }
                } elseif ($current_var[VAR_VALUE] !== false) {
                    $current_var[VAR_VALUE] .= $t_val;
                }
            } else {
                if ($token === '=') {
                    if ($current_var[VAR_VALUE] === false) {
                        $current_var[VAR_VALUE] = '';
                    } else {
                        $current_var[VAR_VALUE] .= $token;
                    }
                } elseif ($token === ';') {
                    if ($current_var[VAR_NAME] && $current_var[VAR_VALUE] !== false) {
                        $current_var[VAR_VALUE] = ltrim($current_var[VAR_VALUE]);
                        $vars[$current_var[VAR_NAME]] = $current_var;
                    }
                    $current_var = array(VAR_NAME => false,
                                        VAR_VALUE => false,
                                        VAR_COMMENT => '');
                } elseif ($current_var[VAR_VALUE] !== false) {
                    $current_var[VAR_VALUE] .= $token;
                }
            }
        }
        return $vars;
    }

    /**
     * [formatComments formatComments adds slashes]
     * @param  [string] $comments [comments in the file]
     * @return [string] [returns comment with slashes]
     */
    function formatComments($comments)
    {
        if (empty($comments)) {
            return '';
        }
        $lines = explode("\n", $comments);
        $output = '';
        foreach ($lines as $line) {
            $line = trim($line);
            if (empty($line)) {
                continue;
            }
            $output .= '// '.$line.NEW_LINE;
        }
        return $output;
    }

    /**
     * [SaveNexus Saves Nexus config files]
     * @param boolean $fname [nexus config file name with path]
     * @param [mixed]  $vars  [merged vars from config file and the $nexusConfig array]
     */
    function SaveNexus($fname = false, $vars)
    {
        $src = "<?php " . NEW_LINE .
       "/*"  . NEW_LINE .
       "* As a work of the United States government, this project is in the public domain within the United States." . NEW_LINE .
       "*/" . NEW_LINE .
       "/*"  . NEW_LINE .
        TAB . "General configuration " . NEW_LINE .
        TAB . "Date: August 9, 2011" . NEW_LINE .
        TAB . "Central place to put org. chart config" . NEW_LINE .
        TAB . "This should be kept outside of web accessible directories" . NEW_LINE .
        "*/" . NEW_LINE . NEW_LINE .
        "// require '../../../config.php';" . NEW_LINE . NEW_LINE .
        "namespace Orgchart;" . NEW_LINE .
        "ini_set('display_errors', 0); // Set to 1 to display errors" . NEW_LINE . NEW_LINE .

        "class Config" . NEW_LINE .
        "{";
        foreach ($vars as $var) {
            $src .= NEW_LINE . TAB . 'public ' . ($var[VAR_TYPE] ? $var[VAR_TYPE] . ' ' : $var['varType'] . ' ') . '$'.($var[VAR_NAME] ? $var[VAR_NAME] : $var['varName']).' = '.($var[VAR_VALUE] ? $var[VAR_VALUE] : $var['varValue']).';' .' '.
            formatComments(wordwrap(($var['varComment'] ? $var['varComment'] : ''), WORD_WRAP));
        }
        $src .= NEW_LINE . NEW_LINE . ' }';

        if ($fname !== false) {
            $fp = @fopen($fname, 'w');
            if ($fp) {
                @fwrite($fp, $src);
                @fclose($fp);
            }
        }
        return $src;
    }

    /**
     * [SavePortal Saves Portal db-config files]
     * @param boolean $fname [portal config file with path]
     * @param [mixed]  $vars  [merged vars from db-config file and the $portalConfig array]
     */
    function SavePortal($fname = false, $vars)
    {
        $dbConfig = array();
        $config = array();
        foreach ($vars as $var) {
            if ($var[VAR_NAME] == 'dbHost' || $var[VAR_NAME] == 'dbName' || $var[VAR_NAME] == 'dbUser' || $var[VAR_NAME] == 'dbPass') {
                $dbConfig[] = array(
            'comment' => formatComments(wordwrap(($var['varComment'] ? $var['varComment'] : ''), WORD_WRAP)),
            'var' => NEW_LINE . TAB . 'public ' . ($var[VAR_TYPE] ? $var[VAR_TYPE] . ' ' : $var['varType'] . ' ') . '$'.($var[VAR_NAME] ? $var[VAR_NAME] : $var['varName']).' = '.($var[VAR_VALUE] ? $var[VAR_VALUE] : $var['varValue']).';' . ' '
              );
            } else {
                $config[] = array(
            'comment' => formatComments(wordwrap(($var['varComment'] ? $var['varComment'] : ''), WORD_WRAP)),
            'var' => NEW_LINE . TAB . 'public ' . ($var[VAR_TYPE] ? $var[VAR_TYPE] . ' ' : $var['varType'] . ' ') . '$'.($var[VAR_NAME] ? $var[VAR_NAME] : $var['varName']).' = '.($var[VAR_VALUE] ? $var[VAR_VALUE] : $var['varValue']).';' . ' '
              );
            }
        }
        $src = "<?php " . NEW_LINE .
          "/*" . NEW_LINE .
           "* As a work of the United States government, this project is in the public domain within the United States." . NEW_LINE .
           "*/" . NEW_LINE .
           "/*" . NEW_LINE .
          TAB . "General configuration " . NEW_LINE .
          TAB . "Date: August 9, 2011" . NEW_LINE .
          TAB . "Central place to put database login information" . NEW_LINE .
          TAB . "This should be kept outside of web accessible directories" . NEW_LINE .
          "*/" . NEW_LINE . NEW_LINE .
          "// require '../../../config.php';" . NEW_LINE . NEW_LINE .
          "ini_set('display_errors', 0); // Set to 1 to display errors" . NEW_LINE . NEW_LINE .
          "class DB_Config" . NEW_LINE .
          "{";
        foreach ($dbConfig as $var) {
            $src .= TAB . $var['var'] . $var['comment'];
        }
        $src .= NEW_LINE . '}' . NEW_LINE;

        $src .= NEW_LINE . "class Config" . NEW_LINE .
      "{";
        foreach ($config as $var) {
            $src .= $var['var'] . $var['comment'];
        }

        $src .= NEW_LINE . ' }';

        if ($fname !== false) {
            $fp = @fopen($fname, 'w');
            if ($fp) {
                @fwrite($fp, $src);
                @fclose($fp);
            }
        }
        return $src;
    }

?>
