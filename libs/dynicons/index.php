<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

/*
    Dynicon (runtime)
    Dynamic icons
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 26, 2011

*/

error_reporting(E_ALL & ~E_NOTICE);
ini_set('display_errors', 0);

/*
    Dynicon for Microsoft Windows
    Dynamic icons (svg to png)
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 26, 2011

*/

if (!class_exists('XSSHelpers'))
{
    include_once dirname(__FILE__) . '/../../libs/php-commons/XSSHelpers.php';
}

class Dynicon
{
    private $cacheDir = 'cache/';

    private $svgSourceDir = 'svg/';

    private $file = '';

    private $cachedFile = '';

    private $preferFormat = 'svg';

    private $width;

    public function __construct($file, $width)
    {
        $file = XSSHelpers::scrubFilename($file);
        $this->file = $file;
        $this->width = $width;
        if (!is_numeric($width) || $width <= 0)
        {
            exit();
        }

        if ($width <= 32)
        {
            $this->preferFormat = 'png';
        }

        $this->cachedFile = $this->cacheDir . $file . $width . '.';
        if (strpos($file, '..') === false && strpos($file, '.svg'))
        {
            if (file_exists($this->cachedFile . $this->preferFormat))
            {
                $this->cachedFile = $this->cachedFile . $this->preferFormat;
                $this->output();
            }
            else
            {
                $this->preferFormat = 'svg';
                $this->cachedFile = $this->cachedFile . 'svg';
                clearstatcache();
                if (file_exists($this->cachedFile))
                {
                    $this->output();
                }
                else
                {
                    if ($this->convert())
                    {
                        $this->output();
                    }
                }
            }
        }
        else
        {
            $this->file = 'emblem-unreadable.svg';
            $this->convert();
            $this->output();
        }
    }

    private function output()
    {
        $time = filemtime($this->cachedFile);
        if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && $_SERVER['HTTP_IF_MODIFIED_SINCE'] == gmdate('D, d M Y H:i:s T', $time))
        {
            header('Last-Modified: ' . gmdate('D, d M Y H:i:s T', $time), true, 304);
        }
        else
        {
            header('Last-Modified: ' . gmdate('D, d M Y H:i:s T', $time), true);
            header('Expires: ' . gmdate('D, d M Y H:i:s T', time() + 604800));
            if ($this->preferFormat == 'svg')
            {
                header('Content-Type: image/svg+xml');
            }
            else
            {
                header('Content-Type: image/png');
            }
            echo file_get_contents($this->cachedFile);
        }
    }

    private function convert()
    {
        $this->file = escapeshellcmd($this->file);
        if (file_exists($this->svgSourceDir . $this->file))
        {
            $xml = simplexml_load_file($this->svgSourceDir . $this->file);
            $rawWidth = trim($xml->attributes()->width);
            $rawHeight = trim($xml->attributes()->height);

            $xmlWidth = is_numeric($rawWidth) ? $rawWidth : substr($rawWidth, 0, strpos($rawWidth, 'px'));
            $xmlHeight = is_numeric($rawHeight) ? $rawHeight : substr($rawHeight, 0, strpos($rawHeight, 'px'));
            $ratio = $this->width / $xmlWidth;
            $newHeight = $ratio * $xmlHeight;

            $xml->attributes()->width = $this->width . 'px';
            $xml->attributes()->height = $newHeight . 'px';
            $xml->addAttribute('viewBox', "0 0 {$xmlWidth} {$xmlHeight}");

            file_put_contents("{$this->cacheDir}{$this->file}{$this->width}.svg", $xml->asXML());

            return true;
        }

        return false;
    }
}

$image = new Dynicon($_GET['img'], $_GET['w']);
