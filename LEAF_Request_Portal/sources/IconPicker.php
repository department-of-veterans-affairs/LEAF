<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    System controls
    Date Created: September 17, 2015

*/

namespace Portal;

class IconPicker
{

    private $login;

    protected array $pickedIcons;

    /**
     * Construct IconPicker
     *
     * @param \App\Leaf\Db $db, Login $login
     */
    public function __construct($db, $login)
    {
        $this->login = $login;
        $this->pickedIcons = array();
    }

    /**
     * Purpose: Get all icons in svg directory and return object with relevant data for each image.
     *
     * @param mixed $folder
     * @param mixed $dynicon_index
     *
     * @return array
     *
     * Created at: 2/24/2023, 11:39:42 AM (America/New_York)
     */
    public function getAllIcons($folder, $dynicon_index, $domain): array
    {
        $images = scandir($folder);

        foreach ($images as $image)
        {
            if (strpos($image, '.svg') > 0)
            {
                $retImg = array(
                    'src' => $dynicon_index . "/?img={$image}&amp;w=32",
                    'alt' => "{$image}",
                    'name' => $this->extractIconName($image)
                );

                if (!isset($_GET['noSVG']) || $_GET['noSVG'] != 1) {
                    $retImg['src'] = "{$domain}{$image}";
                }

                array_push($this->pickedIcons, $retImg);
            }
        }

        return $this->pickedIcons;
    }

    /**
     * Purpose: Map array of icon files names to have formatted names that the user can easily read.
     *
     * @param string $name
     * @return string $formattedName
     */
    private function extractIconName(string $name): string
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
