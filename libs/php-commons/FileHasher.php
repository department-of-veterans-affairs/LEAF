<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

class FileHasher
{
    protected $salt;

    public function __construct($db)
    {
        $res = $db->prepared_query('SELECT * FROM settings WHERE setting="salt"', array());
        $this->salt = isset($res[0]['data']) ? $res[0]['data'] : '';
    }

    /**
     * Generates a sanitized, unique string to use as a filename. The string generated 
     * will be in the format `$recordID_$indicatorID_$series_$fileNameHash`, where 
     * $fileNameHash is the md5 hash of the given $fileName and salt from the database
     *
     * @param   int     $recordID       recordID to associate with this file
     * @param   int     $indicatorID    indicatorID to associate with this file
     * @param   int     $series         series to associate with this file
     * @param   string  $fileName       the name of the file that will be hashed
     *
     * @return string   string in the format `$recordID_$indicatorID_$series_$fileNameHash`, 
     * where $fileNameHash is the md5 hash of the given $fileName and salt from the database
     */
    public function portalFileHash($recordID, $indicatorID, $series, $fileName)
    {
        if (!is_numeric($recordID) || !is_numeric($indicatorID) || !is_numeric($series))
        {
            return '';
        }
        return self::getFileHash($recordID, $indicatorID, $series, $fileName);
    }

    /**
     * Generates a sanitized, unique string to use as a filename. The string generated 
     * will be in the format `$categoryID_$uid_$indicatorID_$fileNameHash`, where 
     * $fileNameHash is the md5 hash of the given $fileName and salt from the database
     *
     * @param   int     $categoryID     categoryID to associate with this file
     * @param   int     $uid            uid to associate with this file
     * @param   int     $indicatorID    indicatorID to associate with this file
     * @param   string  $fileName       the name of the file that will be hashed
     *
     * @return string   string in the format `$categoryID_$uid_$indicatorID_$fileNameHash`, 
     * where $fileNameHash is the md5 hash of the given $fileName and salt from the database
     */
    public function nexusFileHash($categoryID, $uid, $indicatorID, $fileName)
    {
        if (!is_numeric($categoryID) || !is_numeric($uid) || !is_numeric($indicatorID))
        {
            return '';
        }
        return self::getFileHash($categoryID, $uid, $indicatorID, $fileName);
    }

    /**
     * Generates a sanitized, unique string to use as a filename. The string generated 
     * will be in the format `$first_$second_$third_$fileNameHash`, where 
     * $fileNameHash is the md5 hash of the given $fileName and salt from the database.
     *
     * @param   mixed   $first      first to associate with this file; must have string representation
     * @param   mixed   $second     second to associate with this file; must have string representation
     * @param   mixed   $third      third to associate with this file; must have string representation
     * @param   string  $fileName   the name of the file that will be hashed
     *
     * @return string   string in the format `$first_$second_$third_$fileNameHash`, 
     * where $fileNameHash is the md5 hash of the given $fileName and salt from the database
     */
    private function getFileHash($first, $second, $third, $fileName)
    {
        $fileNameHash = md5($fileName . $this->salt);

        return "{$first}_{$second}_{$third}_{$fileNameHash}";
    }
}
