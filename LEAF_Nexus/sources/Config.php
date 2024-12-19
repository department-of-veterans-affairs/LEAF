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

    public $oc_db;

    public $dbName;

    public function __construct(array $site_paths, array $oc_settings)
    {
        $this->title = $oc_settings['heading'];
        $this->city = $oc_settings['subheading'];
        self::$uploadDir = $site_paths['site_uploads'];
    }
}
