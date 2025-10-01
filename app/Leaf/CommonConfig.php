<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

namespace App\Leaf;

class CommonConfig
{
    public $requestWhitelist = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                        'csv', 'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                        'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                        'pbix',
                                        'ai', 'eps',
                                        'pdf',
                                        'txt', 'txml',
                                        'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif',
                                        'vsd',
                                        'rtf',
                                        'json', 'sql', 'rdl',
                                        '3mf', 'gcode', 'stl',
                                        'pub',
                                        'msg', 'ics',
                                        'mht', 'msg', 'xml',
                                        'zip', '7z', 'gz',
                                        'dwg'
                                    );

    public $fileManagerWhitelist = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                            'csv', 'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                            'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                            'pbix',
                                            'ai', 'eps',
                                            'pdf',
                                            'txt',
                                            'htm', 'html',
                                            'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif', 'svg',
                                            'vsd',
                                            'rtf',
                                            'json', 'sql', 'rdl',
                                            'js', 'mjs',
                                            'css',
                                            '3mf', 'gcode', 'stl',
                                            'pub',
                                            'msg', 'ics',
                                            'mht', 'msg', 'xml',
                                            'zip', '7z', 'gz',
                                            'dwg'
                                        );
}

