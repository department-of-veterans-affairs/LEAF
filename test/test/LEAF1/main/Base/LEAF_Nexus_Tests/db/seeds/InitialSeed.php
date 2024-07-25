<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Seed\AbstractSeed;

/**
 * This is all data from LEAF_Nexus/orgchart_boilerplate_empty.sql.
 * The inserts have been broken out here so the database does not need to be recreated just to seed the initial data.
 */
class InitialSeed extends AbstractSeed
{
    public function run()
    {
        $categoriesData = "
            INSERT INTO `categories` (`categoryID`, `parentID`, `dataTable`, `categoryName`, `categoryDescription`, `sort`, `disabled`) VALUES
            ('employee', '', 'employee_data', 'Employee', '', 0, 0),
            ('position', '', 'position_data', 'Position', '', 0, 0),
            ('group', '', 'group_data', 'Group', '', 0, 0);
        ";
        $this->execute($categoriesData);

        $groupsData = "
            INSERT INTO `groups` (`groupID`, `parentID`, `groupTitle`, `groupAbbreviation`, `phoneticGroupTitle`) VALUES
            (1, 0, 'System Administrators', NULL, 'SSTMTMNSTRTRS'),
            (2, 0, 'Everyone', NULL, 'EFRYN'),
            (3, 0, 'Owner', NULL, 'ONR'),
            (4, 0, 'System Reserved.2', NULL, 'SSTMRSRFT'),
            (5, 0, 'System Reserved.3', NULL, 'SSTMRSRFT'),
            (6, 0, 'System Reserved.4', NULL, 'SSTMRSRFT'),
            (7, 0, 'System Reserved.5', NULL, 'SSTMRSRFT'),
            (8, 0, 'System Reserved.6', NULL, 'SSTMRSRFT'),
            (9, 0, 'System Reserved.7', NULL, 'SSTMRSRFT'),
            (10, 0, 'System Reserved.8', NULL, 'SSTMRSRFT'),
            (11, 0, 'Administrative Officers', NULL, 'ATMNSTRTFFSRS');
        ";
        $this->execute($groupsData);

        $indicatorsData = "
            INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES
            (1, 'Photo', 'image', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 1, '2011-11-07 23:55:49', 0, 0),
            (2, 'Pay Plan', 'dropdown\r\n\r\nGS\r\nWG\r\nVM\r\nVN\r\nNS\r\nNA\r\nAD\r\nWS\r\nWL\r\nVP\r\nVC\r\nES', NULL, NULL, NULL, 'position', NULL, NULL, 1, 1, '2011-12-09 06:27:37', 0, 0),
            (3, 'Position Description', 'fileupload', NULL, NULL, NULL, 'position', NULL, NULL, 1, 10, '2011-12-09 06:38:12', 0, 0),
            (4, 'FTE Ceiling', 'number', NULL, NULL, NULL, 'group', NULL, NULL, 1, 1, '2012-01-25 23:46:27', 0, 0),
            (5, 'Phone', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, 1, 1, '2012-03-01 22:57:20', 0, 0),
            (6, 'Email', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, 1, 1, '2012-03-01 22:57:20', 0, 0),
            (7, 'Pager', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 1, '2012-03-01 22:57:47', 0, 0),
            (8, 'Room', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, 1, 1, '2012-03-01 22:57:47', 0, 0),
            (9, 'PD Number', 'text', NULL, NULL, NULL, 'position', NULL, NULL, 1, 6, '2012-03-05 22:47:55', 0, 0),
            (10, 'Logo', 'image', NULL, NULL, NULL, 'group', NULL, NULL, 0, 1, '2012-03-18 06:10:44', 0, 0),
            (11, 'FTE Ceiling', 'number', NULL, '1', NULL, 'position', NULL, NULL, 1, 4, '2012-03-21 05:51:02', 0, 0),
            (12, 'Classification Title', 'text', NULL, NULL, NULL, 'position', NULL, NULL, 1, 5, '2012-03-21 17:02:59', 0, 0),
            (13, 'Series', 'text', NULL, NULL, NULL, 'position', NULL, NULL, 1, 2, '2012-05-21 04:18:07', 0, 0),
            (14, 'Pay Grade', 'text', NULL, NULL, NULL, 'position', NULL, NULL, 1, 3, '2012-05-21 04:19:37', 0, 0),
            (15, 'system', 'json', NULL, NULL, NULL, 'position', NULL, NULL, 0, 99, '2012-05-21 05:32:51', 0, 0),
            (16, 'Mobile', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 1, '2012-05-30 22:51:13', 0, 0),
            (17, 'Current FTE', 'number', NULL, NULL, NULL, 'position', NULL, NULL, 1, 4, '2012-06-13 20:50:19', 0, 0),
            (18, 'Functional Statement', 'fileupload', NULL, NULL, NULL, 'position', NULL, NULL, 1, 15, '2012-06-13 20:51:15', 0, 0),
            (19, 'Total Headcount', 'number', NULL, NULL, NULL, 'position', NULL, NULL, 1, 4, '2012-11-29 23:05:28', 0, 0),
            (20, 'EIN', 'number', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 1, '2013-05-22 22:24:34', 0, 0),
            (21, 'Recruitment Documents', 'fileupload', NULL, NULL, NULL, 'position', NULL, NULL, 1, 11, '2015-05-01 15:11:39', 0, 0),
            (22, 'Organization Code', 'text', NULL, NULL, NULL, 'position', NULL, NULL, 1, 20, '2015-05-01 15:11:44', 0, 0);
        ";
        $this->execute($indicatorsData);

        $positionsData = "
            INSERT INTO `positions` (`positionID`, `parentID`, `positionTitle`, `phoneticPositionTitle`, `numberFTE`) VALUES
            (1, 0, 'Medical Center Director', 'MTKLSNTRTRKTR', 1);
        ";
        $this->execute($positionsData);

        $positionsDataData = "
            INSERT INTO `position_data` (`positionID`, `indicatorID`, `data`, `author`, `timestamp`) VALUES
            (1, 15, '{&quot;1&quot;:{&quot;zoom&quot;:2,&quot;x&quot;:361,&quot;y&quot;:103}}', 'vhawasgaom1', 1356129251);
        ";
        $this->execute($positionsDataData);

        $settingsData = "
            INSERT INTO `settings` (`setting`, `data`) VALUES
            ('dbversion', '4030'),
            ('salt', '0'),
            ('version', '2743');
        ";
        $this->execute($settingsData);

        $tagHierarchyData = "
            INSERT INTO `tag_hierarchy` (`tag`, `parentTag`) VALUES
            ('quadrad', NULL),
            ('service', 'quadrad');
        ";
        $this->execute($tagHierarchyData);

        $indicatorPrivilegesData = "
            INSERT INTO `indicator_privileges` (`indicatorID`, `categoryID`, `UID`, `read`, `write`, `grant`) VALUES
            (1, 'group', 1, 1, 1, 1),
            (1, 'group', 2, 1, 0, 0),
            (1, 'group', 3, 1, 1, 0),
            (2, 'group', 1, 1, 1, 1),
            (2, 'group', 2, 1, 0, 0),
            (2, 'group', 11, 1, 1, 0),
            (3, 'group', 1, 1, 1, 1),
            (3, 'group', 2, 1, 0, 0),
            (3, 'group', 11, 1, 1, 0),
            (5, 'group', 1, 1, 1, 1),
            (5, 'group', 2, 1, 0, 0),
            (5, 'group', 3, 1, 1, 0),
            (6, 'group', 1, 1, 1, 1),
            (6, 'group', 2, 1, 0, 0),
            (8, 'group', 1, 1, 1, 1),
            (8, 'group', 2, 1, 0, 0),
            (8, 'group', 3, 1, 1, 0),
            (9, 'group', 1, 1, 1, 1),
            (9, 'group', 2, 1, 0, 0),
            (9, 'group', 11, 1, 1, 0),
            (11, 'group', 1, 1, 1, 1),
            (11, 'group', 2, 1, 0, 0),
            (11, 'group', 11, 1, 1, 0),
            (12, 'group', 1, 1, 1, 1),
            (12, 'group', 2, 1, 0, 0),
            (12, 'group', 11, 1, 1, 0),
            (13, 'group', 1, 1, 1, 1),
            (13, 'group', 2, 1, 0, 0),
            (13, 'group', 11, 1, 1, 0),
            (14, 'group', 1, 1, 1, 1),
            (14, 'group', 2, 1, 0, 0),
            (14, 'group', 11, 1, 1, 0),
            (15, 'group', 1, 1, 1, 1),
            (15, 'group', 2, 1, 0, 0),
            (15, 'group', 11, 1, 1, 0),
            (17, 'group', 1, 1, 1, 1),
            (17, 'group', 2, 1, 0, 0),
            (17, 'group', 11, 1, 1, 0),
            (18, 'group', 1, 1, 1, 1),
            (18, 'group', 2, 1, 0, 0),
            (18, 'group', 11, 1, 1, 0),
            (19, 'group', 1, 1, 1, 1),
            (19, 'group', 2, 1, 0, 0),
            (19, 'group', 11, 1, 1, 0);
        ";
        $this->execute($indicatorPrivilegesData);
    }
}
