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


    public function __construct($db, $login)
    {
        $this->login = $login;
    }

    // return array of icons with file address and corresponding name.
    public function getAllIcons()
    {
        $folder = '../../libs/dynicons/svg/';
        $images = scandir($folder);
        $retArr = array();

        foreach ($images as $image)
        {
            if (strpos($image, '.svg') > 0)
            {
                $retImg = (object)[];
                $retImg->src = "./?img={$image}&amp;w=32";
                $retImg->alt = "{$image}";
                $retImg->name = $this->extractIconName($image);
                array_push($retArr, $retImg);
            }
        }

        return $retArr;
    }

    // map array of icon file names to have formatted names that the user can easily read.
    private function extractIconName($name)
    {
        $formattedName = str_replace(".svg", "", $name);
        $formattedName = str_replace("-", " ", mb_convert_case($formattedName, MB_CASE_TITLE, "UTF-8"));
        $formattedName = str_replace("_", " - ", $formattedName);
        return $formattedName;
    }
}