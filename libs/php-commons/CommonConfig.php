<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

class CommonConfig
{
    public $requestWhitelist = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                        'csv', 'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                        'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                        'ai', 'eps',
                                        'pdf',
                                        'txt',
                                        'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif',
                                        'vsd',
                                        'rtf',
                                        'json',
                                        'pub',
                                        'msg', 'ics',
                                        'mht', 'msg', 'xml',
                                        'zip', '7z',
                                    );
    
    public $fileManagerWhitelist = array('doc', 'docx', 'docm', 'dotx', 'dotm',
                                            'csv', 'xls', 'xlsx', 'xlsm', 'xltx', 'xltm', 'xlsb', 'xlam',
                                            'ppt', 'pptx', 'pptm', 'potx', 'potm', 'ppam', 'ppsx', 'ppsm', 'ppts',
                                            'ai', 'eps',
                                            'pdf',
                                            'txt',
                                            'htm', 'html',
                                            'png', 'jpg', 'jpeg', 'bmp', 'gif', 'tif', 'svg',
                                            'vsd',
                                            'rtf',
                                            'json',
                                            'js',
                                            'css',
                                            'pub',
                                            'msg', 'ics',
                                            'mht', 'msg', 'xml',
                                            'zip', '7z',
                                        );

    public $awsSharedConfig = array(
        //'profile' => 'default',
        'region' => 'us-east-1',
        'credentials' => [
            'key' => 'YOUR_AWS_KEY_HERE',
            'secret' => 'YOUR_AWS_SECRET_HERE',
        ],
        'version' => 'latest',
        'S3' => [
            'bucket' => 'YOUR_AWS_BUCKET_HERE'
            //'debug' => 'false' // default is false
        ]
    );
}