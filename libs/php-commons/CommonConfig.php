<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */
/*
 * test comment for 4583 
 */

namespace Leaf;

class CommonConfig
{
    public $requestWhitelist = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                        'csv', 'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                        'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                        'pbix',
                                        'ai', 'eps',
                                        'pdf',
                                        'txt',
                                        'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif',
                                        'vsd',
                                        'rtf',
                                        'json', 'sql', 'rdl',
                                        'pub',
                                        'msg', 'ics',
                                        'mht', 'msg', 'xml',
                                        'zip', '7z',
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
                                            'js',
                                            'css',
                                            'pub',
                                            'msg', 'ics',
                                            'mht', 'msg', 'xml',
                                            'zip', '7z',
                                            'dwg'
                                        );
}
