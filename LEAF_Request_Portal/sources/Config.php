<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace Portal;

class Config
{
    public $title;

    public $city;

    public $adPath; // Active directory path

    public static $uploadDir;    // Directory for user uploads
    // using backslashes (/), with trailing slash

    public static $orgchartPath; // HTTP Path to orgchart with no trailing slash

    public static $orgchartImportTags; // Import org chart groups if they match these tags

    public $descriptionID;     // indicator ID for description field

    public static $emailPrefix;  // Email prefix

    public static $emailCC;    // CCed for every email

    public static $emailBCC;      // BCCed for every email

    public $phonedbName;

    public $db;

    public function __construct(array $site_paths, array $settings)
    {
        $this->title = $settings['heading'];
        $this->city = $settings['subHeading'];
        $this->adPath = $settings['adPath'];
        self::$uploadDir = $site_paths['site_uploads'];
        self::$orgchartPath = $site_paths['orgchart_path'];
        self::$orgchartImportTags = $settings['orgchartImportTags'];
        $this->descriptionID = $settings['descriptionID'];
        self::$emailPrefix = $settings['requestLabel'];
        self::$emailCC = $settings['emailCC'];
        self::$emailBCC = $settings['emailBCC'];
        $this->phonedbName = $site_paths['orgchart_database'];
    }
}
