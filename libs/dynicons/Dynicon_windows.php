<?php
/************************
    Dynicon for Microsoft Windows
    Dynamic icons (svg to png)
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: January 26, 2011

*/


class Dynicon
{
    private $cacheDir = 'cache/';
    private $svgSourceDir = 'svg/';
    private $file = '';
    private $cachedFile = '';
    private $width = null;
    
    function __construct($file, $width)
    {
        $this->file = $file;
        $this->width = $width;
        if(!is_numeric($width) || $width <= 0) {
            exit();
        }

        $this->cachedFile = $this->cacheDir . $file . $width . '.png';
        if(strpos($file, '..') === false && strpos($file, '.svg')) {
            if(file_exists($this->cachedFile)) {
                $this->output();
            }
            else {
                clearstatcache();
                if($this->convert()) {
                    $this->output();
                }
            }
        }
        else {
            $this->file = 'emblem-unreadable.svg';
            $this->convert();
            $this->output();
        }
    }
    
    private function output()
    {
        $time = filemtime($this->cachedFile);
        if(isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) && $_SERVER['HTTP_IF_MODIFIED_SINCE'] == date(DATE_RFC822, $time)) {
            header('Last-Modified: ' . date(DATE_RFC822, $time), true, 304);
        }
        else {
            header('Last-Modified: ' . date(DATE_RFC822, $time));
            header('Expires: ' . date(DATE_RFC822, time() + 604800));
            header('Content-Type: image/png');
            echo file_get_contents($this->cachedFile);
        }
    }
    
    private function convert()
    {
        $this->file = escapeshellcmd($this->file);
        if(file_exists($this->svgSourceDir . $this->file)) {
            system("inkscape\\inkscape.com {$this->svgSourceDir}{$this->file} -w{$this->width} -e {$this->cacheDir}{$this->file}{$this->width}.png 1>&2");
            return true;
        }
        
        return false;
    }
}

?>