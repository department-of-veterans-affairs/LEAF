<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date Created: September 17, 2015

*/

$currDir = dirname(__FILE__);

include_once $currDir . '/../globals.php';

if (!class_exists('XSSHelpers'))
{
    require_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
}
if (!class_exists('CommonConfig'))
{
    require_once dirname(__FILE__) . '/../../libs/php-commons/CommonConfig.php';
}

if(!class_exists('DataActionLogger'))
{
    require_once dirname(__FILE__) . '/../../libs/logger/dataActionLogger.php';
}

class IconPicker 
{

    private $login; 

    /**
     * Construct IconPicker
     * 
     * @param Db $db, Login $login
     */
    public function __construct($db, $login)
    {
        $this->login = $login;
    }

    /**
     * Purpose: Get all icons in svg directory and return object with relevant data for each image.
     * 
     * @return array $retArr
     */
    public function getAllIcons(): array
    {
        $folder = '../../libs/dynicons/svg/';
        $images = scandir($folder);
        $retArr = array();

        foreach ($images as $image)
        {
            if (strpos($image, '.svg') > 0)
            {
                $retImg = array(
                    'src' => "../libs/dynicons/?img={$image}&amp;w=32",
                    'alt' => "{$image}",
                    'name' => $this->extractIconName($image)
                );

                if (!isset($_GET['noSVG']) || $_GET['noSVG'] != 1) {
                    $retImg['src'] = "../libs/dynicons/svg/{$image}";
                }

                array_push($retArr, $retImg);
            }
        }

        return $retArr;
    }

    /**
     * Purpose: Map array of icon files names to have formatted names that the user can easily read.
     * 
     * @param string $name
     * @return string $formattedName
     */
    private function extractIconName($name): string
    {
        if (empty($name)) {
            return '';
        }

        $formattedName = str_replace(".svg", "", $name);
        $formattedName = str_replace("-", " ", mb_convert_case($formattedName, MB_CASE_TITLE, "UTF-8"));
        $formattedName = str_replace("_", " - ", $formattedName);
        return $formattedName;
    }
}