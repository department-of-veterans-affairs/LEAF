<?php
/*
    Dynicon gallery
    Author: Michael Gao (Michael.Gao@va.gov)
    Date: November 27, 2012

*/
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Dynamic icon gallery</title>
    <style type="text/css" media="screen">
        body {
            background-color: #e0e0e0;
            font-family: verdana;
            font-size: 10px;
            word-wrap: break-word;
        }
        .icon {
            float: left;
            width: 100px;
            height: 100px;
            padding: 16px;
            text-align: center;
        }
        .block {
            background-color: white;
            padding: 4px;
            border: 1px solid black;
        }
        img {
        <?php
            if (isset($_GET['noSVG']) && $_GET['noSVG'] == 1)
            {
                echo 'width: 32px;';
            }
            else
            {
                echo 'width: 48px;';
            }
        ?>
        }
    </style>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<div>
<p class="block" style="font-size: 14px">
Dynicons dynamically creates and caches PNG images for the purpose of rapidly embedding icons of arbitrary size.
</p> 
<div class="block" style="font-size: 12px">Usage:
<ul>
    <li><span style="font-size: 14px; font-family: courier new">&lt;img src="dynicons/?img=<b>[SVG file]</b>&amp;w=<b>[width in pixels]</b>" /&gt;</span></li>
    <li>Relative paths recommended</li>
    <li><a href="?noSVG=1">Click here if you are using IE7 or if your browser does not support SVG.</a></li>
</ul>
</div>
<br />
</div>
<?php

$folder = './svg/';
$images = scandir($folder);

$counter = 0;
foreach ($images as $image)
{
    if (strpos($image, '.svg') > 0)
    {
        if (isset($_GET['noSVG']) && $_GET['noSVG'] == 1)
        {
            echo "<div class='icon'>
                    <img src='./?img={$image}&amp;w=32' alt='{$image}' /><br />
                    {$image}</div>";
        }
        else
        {
            echo "<div class='icon'>
                    <img src='./svg/{$image}' alt='{$image}' /><br />
                    {$image}</div>";
        }
        $counter++;
    }
}

echo "<div style='clear: both' /><div class='block'>{$counter} icons. Sourced from <a href=\"http://tango.freedesktop.org/\">Tango Deskop Project</a>, <a href=\"https://commons.wikimedia.org/wiki/GNOME_Desktop_icons\">GNOME</a>, <a href=\"http://www.aiga.org/symbol-signs/\">AIGA</a>, and the Public Domain</div>";
?>

</body>
</html>
