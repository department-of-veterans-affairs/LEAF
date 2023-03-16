<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Orgchart;

class Config
{
    public $title;

    public $city;

    public $adPath; // Active directory path

    public static $uploadDir;    // Directory for user uploads
    // using backslashes (/), with trailing slash

    public static $ERM_Sites; // HTTP Path to orgchart with no trailing slash

    public function __construct(array $settings, array $site_paths)
    {
        $this->title = $settings['heading'];
        $this->city = $settings['subHeading'];
        $this->adPath = $settings['adPath'];
        $this->uploadDir = $site_paths['site_uploads'];
        $this->ERM_Sites = $settings['ERM_Sites'];
    }
}
