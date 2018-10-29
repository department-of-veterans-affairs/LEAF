<?php

declare(strict_types = 1);
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

if (!class_exists('XSSHelpers'))
{
    include '../../libs/php-commons/FileHasher.php';
}

use PHPUnit\Framework\TestCase;

/**
 * Tests libs/php-commons/FileHasher.php
 */
final class FileHasherTest extends TestCase
{
    private static $fileHasher;

    private static $db;

    private static $oldSalt;

    public static function setUpBeforeClass()
    {
        $db_config = new DB_Config();
        self::$db = new DB($db_config->dbHost, $db_config->dbUser, $db_config->dbPass, $db_config->dbName);

        //if salt exists, set salt to empty string for testing
        //is salt doesn't exist, empty string is default in FileHasher.php
        $res = self::$db->query('SELECT data FROM settings WHERE setting="salt";');
        if(count($res))
        {
            self::$oldSalt = $res[0]['data'];
            self::$db->query('UPDATE settings SET data = "" WHERE setting="salt";');
        }
        self::$fileHasher = new FileHasher(self::$db);
    }

    public static function tearDownAfterClass()
    {
        //if salt was set to empty string earlier, set it back
        if(isset(self::$oldSalt))
        {
            self::$db->query('UPDATE settings SET data = '.self::$oldSalt.' WHERE setting="salt";');
        }
    }

    /**
     * Tests FileHasher::nexusFileHash($categoryID, $uid, $indicatorID, $fileName)
     *
     * Tests sanitizing HTML with anchor elements.
     */
    public function testNexusFileHash() : void
    {
        $inOutNum1 = array(-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,);
        $inOutNum2 = array(-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,);
        $inOutNum3 = array(-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,);

        $inOutNumBad1 = array("word",null,array(),new stdClass());
        $inOutFilenames =   array(
                                "filename.jpg" => "03e6eda992afdeda6b2acaed17722515",
                                "filename_123.jpg" => "60269aca1bea5a9c3e805b3ebc611cea",
                                "abc_filename_123.jpg" => "5722452ccb49cbe20641168f55188bbf",
                                "abc filename 123.jpg" => "348e4bd94563889d4fff4390fbd4025c",
                                "/../badfolder/badfile.exe" => "e5858228c652f41e36a49a8fa3dc9bf0"
                            );

        //all good                            
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNum1); $i++)
            {
                for($j = 0; $j < count($inOutNum2); $j++)
                {
                    for($k = 0; $k < count($inOutNum3); $k++)
                    {
                        $this->assertEquals(
                            "{$inOutNum1[$i]}_{$inOutNum2[$j]}_{$inOutNum3[$k]}_{$out}",
                            self::$fileHasher->portalFileHash($inOutNum1[$i],$inOutNum2[$j],$inOutNum3[$k],$in)
                        );

                        $this->assertEquals(
                            "{$inOutNum1[$i]}_{$inOutNum2[$j]}_{$inOutNum3[$k]}_{$out}",
                            self::$fileHasher->nexusFileHash($inOutNum1[$i],$inOutNum2[$j],$inOutNum3[$k],$in)
                        );
                    }
                }   
            }
        }
        //first bad
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNumBad1); $i++)
            {
                for($j = 0; $j < count($inOutNum2); $j++)
                {
                    for($k = 0; $k < count($inOutNum3); $k++)
                    {
                        $this->assertEquals(
                            "",
                            self::$fileHasher->portalFileHash($inOutNumBad1[$i],$inOutNum2[$j],$inOutNum3[$k],$in)
                        );

                        $this->assertEquals(
                            "",
                            self::$fileHasher->nexusFileHash($inOutNumBad1[$i],$inOutNum2[$j],$inOutNum3[$k],$in)
                        );
                    }
                }   
            }
        }
        //second bad
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNum1); $i++)
            {
                for($j = 0; $j < count($inOutNumBad1); $j++)
                {
                    for($k = 0; $k < count($inOutNum3); $k++)
                    {
                        $this->assertEquals(
                            "",
                            self::$fileHasher->portalFileHash($inOutNum1[$i],$inOutNumBad1[$j],$inOutNum3[$k],$in)
                        );

                        $this->assertEquals(
                            "",
                            self::$fileHasher->nexusFileHash($inOutNum1[$i],$inOutNumBad1[$j],$inOutNum3[$k],$in)
                        );
                    }
                }   
            }
        }
        //third bad
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNum1); $i++)
            {
                for($j = 0; $j < count($inOutNum2); $j++)
                {
                    for($k = 0; $k < count($inOutNumBad1); $k++)
                    {
                        $this->assertEquals(
                            "",
                            self::$fileHasher->portalFileHash($inOutNum1[$i],$inOutNum2[$j],$inOutNumBad1[$k],$in)
                        );

                        $this->assertEquals(
                            "",
                            self::$fileHasher->nexusFileHash($inOutNum1[$i],$inOutNum2[$j],$inOutNumBad1[$k],$in)
                        );
                    }
                }   
            }
        }
        //first and second bad
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNumBad1); $i++)
            {
                for($j = 0; $j < count($inOutNumBad1); $j++)
                {
                    for($k = 0; $k < count($inOutNum3); $k++)
                    {
                        $this->assertEquals(
                            "",
                            self::$fileHasher->portalFileHash($inOutNumBad1[$i],$inOutNumBad1[$j],$inOutNum3[$k],$in)
                        );

                        $this->assertEquals(
                            "",
                            self::$fileHasher->nexusFileHash($inOutNumBad1[$i],$inOutNumBad1[$j],$inOutNum3[$k],$in)
                        );
                    }
                }   
            }
        }
        //first and third bad
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNumBad1); $i++)
            {
                for($j = 0; $j < count($inOutNum2); $j++)
                {
                    for($k = 0; $k < count($inOutNumBad1); $k++)
                    {
                        $this->assertEquals(
                            "",
                            self::$fileHasher->portalFileHash($inOutNumBad1[$i],$inOutNum2[$j],$inOutNumBad1[$k],$in)
                        );

                        $this->assertEquals(
                            "",
                            self::$fileHasher->nexusFileHash($inOutNumBad1[$i],$inOutNum2[$j],$inOutNumBad1[$k],$in)
                        );
                    }
                }   
            }
        }
        //second and third bad
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNum1); $i++)
            {
                for($j = 0; $j < count($inOutNumBad1); $j++)
                {
                    for($k = 0; $k < count($inOutNumBad1); $k++)
                    {
                        $this->assertEquals(
                            "",
                            self::$fileHasher->portalFileHash($inOutNum1[$i],$inOutNumBad1[$j],$inOutNumBad1[$k],$in)
                        );

                        $this->assertEquals(
                            "",
                            self::$fileHasher->nexusFileHash($inOutNum1[$i],$inOutNumBad1[$j],$inOutNumBad1[$k],$in)
                        );
                    }
                }   
            }
        }
        //all bad
        foreach($inOutFilenames as $in => $out)
        {
            for($i = 0; $i < count($inOutNumBad1); $i++)
            {
                for($j = 0; $j < count($inOutNumBad1); $j++)
                {
                    for($k = 0; $k < count($inOutNumBad1); $k++)
                    {
                        $this->assertEquals(
                            "",
                            self::$fileHasher->portalFileHash($inOutNumBad1[$i],$inOutNumBad1[$j],$inOutNumBad1[$k],$in)
                        );

                        $this->assertEquals(
                            "",
                            self::$fileHasher->nexusFileHash($inOutNumBad1[$i],$inOutNumBad1[$j],$inOutNumBad1[$k],$in)
                        );
                    }
                }   
            }
        }
    }
}
