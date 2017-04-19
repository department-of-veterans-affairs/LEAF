
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE IF NOT EXISTS `categories` (
  `categoryID` enum('employee','position','group') NOT NULL,
  `parentID` varchar(50) NOT NULL,
  `dataTable` varchar(20) NOT NULL,
  `categoryName` varchar(50) NOT NULL,
  `categoryDescription` varchar(255) NOT NULL,
  `sort` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `disabled` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`categoryID`, `parentID`, `dataTable`, `categoryName`, `categoryDescription`, `sort`, `disabled`) VALUES
('employee', '', 'employee_data', 'Employee', '', 0, 0),
('position', '', 'position_data', 'Position', '', 0, 0),
('group', '', 'group_data', 'Group', '', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE IF NOT EXISTS `employee` (
  `empUID` mediumint(8) unsigned NOT NULL,
  `userName` varchar(30) NOT NULL,
  `lastName` varchar(30) NOT NULL,
  `firstName` varchar(30) NOT NULL,
  `middleName` varchar(30) NOT NULL,
  `phoneticFirstName` varchar(20) NOT NULL,
  `phoneticLastName` varchar(20) NOT NULL,
  `AD_objectGUID` varchar(40) NOT NULL,
  `deleted` int(10) unsigned NOT NULL DEFAULT '0',
  `lastUpdated` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `employee_data`
--

CREATE TABLE IF NOT EXISTS `employee_data` (
  `empUID` mediumint(8) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `employee_data_history`
--

CREATE TABLE IF NOT EXISTS `employee_data_history` (
  `empUID` mediumint(8) unsigned NOT NULL,
  `indicatorID` tinyint(3) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `employee_privileges`
--

CREATE TABLE IF NOT EXISTS `employee_privileges` (
  `empUID` mediumint(8) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` smallint(5) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE IF NOT EXISTS `groups` (
  `groupID` smallint(5) unsigned NOT NULL,
  `parentID` smallint(5) unsigned NOT NULL DEFAULT '0',
  `groupTitle` varchar(250) NOT NULL,
  `groupAbbreviation` varchar(20) DEFAULT NULL,
  `phoneticGroupTitle` varchar(250) NOT NULL DEFAULT ''
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `groups`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `group_data`
--

CREATE TABLE IF NOT EXISTS `group_data` (
  `groupID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `group_data_history`
--

CREATE TABLE IF NOT EXISTS `group_data_history` (
  `groupID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `group_privileges`
--

CREATE TABLE IF NOT EXISTS `group_privileges` (
  `groupID` smallint(5) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` mediumint(8) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `group_tags`
--

CREATE TABLE IF NOT EXISTS `group_tags` (
  `groupID` smallint(6) NOT NULL,
  `tag` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `indicators`
--

CREATE TABLE IF NOT EXISTS `indicators` (
  `indicatorID` smallint(5) NOT NULL,
  `name` varchar(50) NOT NULL,
  `format` text NOT NULL,
  `description` varchar(50) DEFAULT NULL,
  `default` varchar(20) DEFAULT NULL,
  `parentID` smallint(5) unsigned DEFAULT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `html` varchar(255) DEFAULT NULL,
  `jsSort` varchar(255) DEFAULT NULL,
  `required` tinyint(4) NOT NULL DEFAULT '0',
  `sort` tinyint(4) NOT NULL DEFAULT '1',
  `timeAdded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `encrypted` tinyint(1) NOT NULL DEFAULT '0',
  `disabled` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `indicators`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `indicator_privileges`
--

CREATE TABLE IF NOT EXISTS `indicator_privileges` (
  `indicatorID` smallint(5) NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` mediumint(8) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `indicator_privileges`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `positions`
--

CREATE TABLE IF NOT EXISTS `positions` (
  `positionID` smallint(5) unsigned NOT NULL,
  `parentID` smallint(6) unsigned NOT NULL DEFAULT '0',
  `positionTitle` varchar(100) NOT NULL,
  `phoneticPositionTitle` varchar(100) NOT NULL DEFAULT '',
  `numberFTE` tinyint(3) unsigned NOT NULL DEFAULT '1'
) ENGINE=InnoDB AUTO_INCREMENT=164 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `positions`
--

INSERT INTO `positions` (`positionID`, `parentID`, `positionTitle`, `phoneticPositionTitle`, `numberFTE`) VALUES
(1, 0, 'Medical Center Director', 'MTKLSNTRTRKTR', 1);

-- --------------------------------------------------------

--
-- Table structure for table `position_data`
--

CREATE TABLE IF NOT EXISTS `position_data` (
  `positionID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `position_data`
--

INSERT INTO `position_data` (`positionID`, `indicatorID`, `data`, `author`, `timestamp`) VALUES
(1, 15, '{&quot;1&quot;:{&quot;zoom&quot;:2,&quot;x&quot;:361,&quot;y&quot;:103}}', 'vhawasgaom1', 1356129251);

-- --------------------------------------------------------

--
-- Table structure for table `position_data_history`
--

CREATE TABLE IF NOT EXISTS `position_data_history` (
  `positionID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `position_privileges`
--

CREATE TABLE IF NOT EXISTS `position_privileges` (
  `positionID` smallint(5) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` mediumint(8) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `position_tags`
--

CREATE TABLE IF NOT EXISTS `position_tags` (
  `positionID` smallint(6) NOT NULL,
  `tag` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `relation_employee_backup`
--

CREATE TABLE IF NOT EXISTS `relation_employee_backup` (
  `empUID` mediumint(8) unsigned NOT NULL,
  `backupEmpUID` mediumint(8) unsigned NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT '0',
  `approverUserName` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `relation_group_employee`
--

CREATE TABLE IF NOT EXISTS `relation_group_employee` (
  `groupID` smallint(6) unsigned NOT NULL,
  `empUID` mediumint(8) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `relation_group_position`
--

CREATE TABLE IF NOT EXISTS `relation_group_position` (
  `groupID` smallint(6) unsigned NOT NULL,
  `positionID` smallint(6) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `relation_position_employee`
--

CREATE TABLE IF NOT EXISTS `relation_position_employee` (
  `positionID` smallint(6) unsigned NOT NULL,
  `empUID` mediumint(8) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE IF NOT EXISTS `sessions` (
  `sessionKey` varchar(40) NOT NULL,
  `variableKey` varchar(40) NOT NULL DEFAULT '',
  `data` text NOT NULL,
  `lastModified` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE IF NOT EXISTS `settings` (
  `setting` varchar(30) NOT NULL,
  `data` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`setting`, `data`) VALUES
('dbversion', '4030'),
('salt', '0'),
('version', '2743');

-- --------------------------------------------------------

--
-- Table structure for table `tag_hierarchy`
--

CREATE TABLE IF NOT EXISTS `tag_hierarchy` (
  `tag` varchar(50) NOT NULL,
  `parentTag` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tag_hierarchy`
--

INSERT INTO `tag_hierarchy` (`tag`, `parentTag`) VALUES
('quadrad', NULL),
('service', 'quadrad');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD KEY `parentID` (`parentID`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`empUID`),
  ADD UNIQUE KEY `username` (`userName`),
  ADD KEY `lastName` (`lastName`),
  ADD KEY `firstName` (`firstName`),
  ADD KEY `phoneticFirstName` (`phoneticFirstName`),
  ADD KEY `phoneticLastName` (`phoneticLastName`),
  ADD KEY `deleted` (`deleted`),
  ADD KEY `lastUpdated` (`lastUpdated`);

--
-- Indexes for table `employee_data`
--
ALTER TABLE `employee_data`
  ADD PRIMARY KEY (`empUID`,`indicatorID`),
  ADD KEY `indicatorID` (`indicatorID`);

--
-- Indexes for table `employee_data_history`
--
ALTER TABLE `employee_data_history`
  ADD KEY `empUID` (`empUID`,`indicatorID`),
  ADD KEY `timestamp` (`timestamp`);

--
-- Indexes for table `employee_privileges`
--
ALTER TABLE `employee_privileges`
  ADD UNIQUE KEY `empUID` (`empUID`,`categoryID`,`UID`);

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`groupID`),
  ADD KEY `parentID` (`parentID`),
  ADD KEY `groupAbbreviation` (`groupAbbreviation`),
  ADD KEY `groupTitle` (`groupTitle`);

--
-- Indexes for table `group_data`
--
ALTER TABLE `group_data`
  ADD PRIMARY KEY (`groupID`,`indicatorID`),
  ADD KEY `indicatorID` (`indicatorID`);

--
-- Indexes for table `group_data_history`
--
ALTER TABLE `group_data_history`
  ADD KEY `timestamp` (`timestamp`),
  ADD KEY `groupID` (`groupID`,`indicatorID`);

--
-- Indexes for table `group_privileges`
--
ALTER TABLE `group_privileges`
  ADD UNIQUE KEY `groupID` (`groupID`,`categoryID`,`UID`);

--
-- Indexes for table `group_tags`
--
ALTER TABLE `group_tags`
  ADD UNIQUE KEY `groupID` (`groupID`,`tag`),
  ADD KEY `tag` (`tag`);

--
-- Indexes for table `indicators`
--
ALTER TABLE `indicators`
  ADD PRIMARY KEY (`indicatorID`),
  ADD KEY `parentID` (`parentID`),
  ADD KEY `sort` (`sort`),
  ADD KEY `categoryID` (`categoryID`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `indicator_privileges`
--
ALTER TABLE `indicator_privileges`
  ADD UNIQUE KEY `indicatorID` (`indicatorID`,`categoryID`,`UID`);

--
-- Indexes for table `positions`
--
ALTER TABLE `positions`
  ADD PRIMARY KEY (`positionID`),
  ADD KEY `positionTitle` (`positionTitle`),
  ADD KEY `numberFTE` (`numberFTE`),
  ADD KEY `parentID` (`parentID`),
  ADD KEY `phoneticPositionTitle` (`phoneticPositionTitle`);

--
-- Indexes for table `position_data`
--
ALTER TABLE `position_data`
  ADD PRIMARY KEY (`positionID`,`indicatorID`),
  ADD KEY `indicatorID` (`indicatorID`);

--
-- Indexes for table `position_data_history`
--
ALTER TABLE `position_data_history`
  ADD KEY `timestamp` (`timestamp`),
  ADD KEY `positionID` (`positionID`,`indicatorID`);

--
-- Indexes for table `position_privileges`
--
ALTER TABLE `position_privileges`
  ADD UNIQUE KEY `positionID` (`positionID`,`categoryID`,`UID`);

--
-- Indexes for table `position_tags`
--
ALTER TABLE `position_tags`
  ADD UNIQUE KEY `positionID` (`positionID`,`tag`),
  ADD KEY `tag` (`tag`);

--
-- Indexes for table `relation_employee_backup`
--
ALTER TABLE `relation_employee_backup`
  ADD UNIQUE KEY `empUID` (`empUID`,`backupEmpUID`);

--
-- Indexes for table `relation_group_employee`
--
ALTER TABLE `relation_group_employee`
  ADD UNIQUE KEY `groupID_2` (`groupID`,`empUID`),
  ADD KEY `groupID` (`groupID`),
  ADD KEY `empUID` (`empUID`);

--
-- Indexes for table `relation_group_position`
--
ALTER TABLE `relation_group_position`
  ADD UNIQUE KEY `groupID_2` (`groupID`,`positionID`),
  ADD KEY `groupID` (`groupID`),
  ADD KEY `positionID` (`positionID`);

--
-- Indexes for table `relation_position_employee`
--
ALTER TABLE `relation_position_employee`
  ADD UNIQUE KEY `positionID_2` (`positionID`,`empUID`),
  ADD KEY `positionID` (`positionID`),
  ADD KEY `empUID` (`empUID`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD UNIQUE KEY `sessionKey` (`sessionKey`,`variableKey`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`setting`);

--
-- Indexes for table `tag_hierarchy`
--
ALTER TABLE `tag_hierarchy`
  ADD PRIMARY KEY (`tag`),
  ADD KEY `parentTag` (`parentTag`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `empUID` mediumint(8) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `groupID` smallint(5) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `indicators`
--
ALTER TABLE `indicators`
  MODIFY `indicatorID` smallint(5) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=23;
--
-- AUTO_INCREMENT for table `positions`
--
ALTER TABLE `positions`
  MODIFY `positionID` smallint(5) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;