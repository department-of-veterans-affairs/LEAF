<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

class CommonConfig
{
    public $requestWhitelist = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                        'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                        'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                        'ai', 'eps',
                                        'pdf',
                                        'txt',
                                        'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif',
                                        'vsd',
                                        'rtf',
                                        'mht', 'htm', 'html', 'msg', 'xml',
                                        'pub',
                                    );
    
    //doesn't have jpeg, mht, htm, xml;  has js, css, ics, svg
    public $fileManagerWhitelist = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                            'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                            'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                            'ai', 'eps',
                                            'pdf',
                                            'txt',
                                            'html',
                                            'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif', 'svg',
                                            'vsd',
                                            'rtf',
                                            'js',
                                            'css',
                                            'pub',
                                            'msg', 'ics',
                                            'mht', 'htm', 'html', 'msg', 'xml',
                                        );

    //doesn't have pub; has ppts; 
    public $fileManagerWhitelist_nexus = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                                'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                                'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                                'ai', 'eps',
                                                'pdf',
                                                'txt',
                                                'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif',
                                                'vsd',
                                                'rtf',
                                                'mht', 'htm', 'html', 'msg', 'xml', );
}