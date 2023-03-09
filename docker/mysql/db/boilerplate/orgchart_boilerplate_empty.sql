
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE IF NOT EXISTS `cache` (
  `cacheID` varchar(40) NOT NULL,
  `data` mediumtext NOT NULL,
  `cacheTime` int unsigned NOT NULL,
  PRIMARY KEY `cacheID` (`cacheID`)
);

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
  `disabled` tinyint(4) NOT NULL DEFAULT '0',
  INDEX `parentID` (`parentID`)
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
  `empUID` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `userName` varchar(30) NOT NULL,
  `lastName` varchar(30) NOT NULL,
  `firstName` varchar(30) NOT NULL,
  `middleName` varchar(30) NOT NULL,
  `phoneticFirstName` varchar(20) NOT NULL,
  `phoneticLastName` varchar(20) NOT NULL,
  `domain` varchar(16) COLLATE 'utf8_general_ci' NULL,
  `deleted` int(10) unsigned NOT NULL DEFAULT '0',
  `lastUpdated` int(10) unsigned NOT NULL DEFAULT '0',
  `new_empUUID` VARCHAR(36) NULL,
  PRIMARY KEY (`empUID`),
  UNIQUE KEY `username` (`userName`),
  INDEX `lastName` (`lastName`),
  INDEX `firstName` (`firstName`),
  INDEX `phoneticFirstName` (`phoneticFirstName`),
  INDEX `phoneticLastName` (`phoneticLastName`),
  INDEX `deleted` (`deleted`),
  INDEX `lastUpdated` (`lastUpdated`),
  INDEX `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`empUID`, `userName`, `lastName`, `firstName`) VALUES
(1, 'vhawasgaom1', 'Gao', 'Michael'),
(2, 'OITORLNeranP', 'Nerantzinis', 'Panaghis'),
(3, 'oitbacholcoj', 'Holcomb', 'Jamie'),
(4, 'OITmiwottins', 'Ottinger', 'Shane'),
(5, 'VHAHONGardnS', 'Gardner', 'Sulgeiry'),
(6, 'OITnhmhanscc', 'Hanscom', 'Carrie'),
(7, 'OITannfrettr', 'Fretter', 'Raphael'),
(8, 'OITcleShaffM', 'Shaffer', 'Michael'),
(9, 'oitsdcrodrij', 'Rodriguez-Sanchez', 'Juan'),
(10, 'vhacpkshaves', 'Schavee', 'Susan'),
(11, 'VHAJITTurneA', 'Turner Sumner', 'Amanda'),
(12, 'OITBIRRichaM1', 'Richard', 'Max');

-- --------------------------------------------------------

--
-- Table structure for table `data_action_log`
--

CREATE TABLE IF NOT EXISTS `data_action_log` (
  `empUID` varchar(36) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` varchar(45) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `timestamp` DATETIME DEFAULT NULL,
  `userDisplay` VARCHAR(255) NULL,
  PRIMARY KEY (`id`)
);

-- --------------------------------------------------------

--
-- Table structure for table `data_log_items`
--

CREATE TABLE IF NOT EXISTS `data_log_items` (
  `data_action_log_fk` int(11) NOT NULL,
  `tableName` varchar(75) NOT NULL,
  `column` varchar(75) NOT NULL,
  `value` TEXT NOT NULL,
  `displayValue` varchar(256),
  PRIMARY KEY (`data_action_log_fk`,`tableName`,`column`)
);

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
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `empUID` (`empUID`,`categoryID`,`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE IF NOT EXISTS `groups` (
  `groupID` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `parentID` smallint(5) unsigned NOT NULL DEFAULT '0',
  `groupTitle` varchar(250) NOT NULL,
  `groupAbbreviation` VARCHAR(250) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `phoneticGroupTitle` varchar(250) NOT NULL DEFAULT '',
  PRIMARY KEY (`groupID`),
  INDEX `parentID` (`parentID`),
  INDEX `groupAbbreviation` (`groupAbbreviation`),
  INDEX `groupTitle` (`groupTitle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
-- Table structure for table `group_privileges`
--

CREATE TABLE IF NOT EXISTS `group_privileges` (
  `groupID` smallint(6) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` mediumint(8) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `groupID` (`groupID`,`categoryID`,`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `group_tags`
--

CREATE TABLE IF NOT EXISTS `group_tags` (
  `groupID` smallint(6) unsigned NOT NULL,
  `tag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY `groupID` (`groupID`,`tag`),
  INDEX `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `indicators`
--

CREATE TABLE IF NOT EXISTS `indicators` (
  `indicatorID` smallint(5) NOT NULL AUTO_INCREMENT,
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
  `disabled` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`indicatorID`),
  INDEX `parentID` (`parentID`),
  INDEX `sort` (`sort`),
  INDEX `categoryID` (`categoryID`),
  INDEX `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `indicators`
--

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `jsSort`, `required`, `sort`, `timeAdded`, `encrypted`, `disabled`) VALUES
(1, 'Photo', 'image', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 1, '2011-11-07 23:55:49', 0, 0),
(2, 'Pay Plan', 'dropdown\r\n\r\nGS\r\nWG\r\nVM\r\nVN\r\nNS\r\nNA\r\nAD\r\nWS\r\nWL\r\nVP\r\nVC\r\nES\r\nFEE\r\nLVN\r\nRN\r\nL\r\nU\r\nQ\r\nK\r\nV1', NULL, NULL, NULL, 'position', NULL, NULL, 1, 1, '2011-12-09 06:27:37', 0, 0),
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
(22, 'Organization Code', 'text', NULL, NULL, NULL, 'position', NULL, NULL, 1, 20, '2015-05-01 15:11:44', 0, 0),
(23, 'AD Title', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 1, CURRENT_TIMESTAMP, 0, 0),
(24, 'Contact Info', 'text', NULL, NULL, NULL, 'group', NULL, NULL, 1, 1, CURRENT_TIMESTAMP, 0, 0),
(25, 'Location', 'text', NULL, NULL, NULL, 'group', NULL, NULL, 1, 1, CURRENT_TIMESTAMP, 0, 0),
(26, 'HR Smart Position Number', 'number', NULL, NULL, NULL, 'position', NULL, NULL, 1, 6, CURRENT_TIMESTAMP, 0, 0),
(27, 'LEAF Developer Console Access', 'checkbox\r\nYes', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 98, CURRENT_TIMESTAMP, 0, 0),
(28, 'LEAF Developer Console Request Reference', 'text', NULL, NULL, NULL, 'employee', NULL, NULL, 0, 99, CURRENT_TIMESTAMP, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `group_data`
--

CREATE TABLE `group_data` (
  `groupID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`groupID`,`indicatorID`),
  KEY `indicatorID` (`indicatorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `group_data_history`
--

CREATE TABLE IF NOT EXISTS `group_data_history` (
  `groupID` smallint(6) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  INDEX `timestamp` (`timestamp`),
  INDEX `groupID` (`groupID`,`indicatorID`)
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
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`empUID`,`indicatorID`),
  INDEX `indicatorID` (`indicatorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `employee_data`
--

INSERT INTO `employee_data` (`empUID`, `indicatorID`, `data`, `author`) VALUES
(1, 6, 'Michael.Gao@va.gov', 'system'),
(2, 6, 'Panaghis.Nerantzinis@va.gov', 'system'),
(3, 6, 'jamie.holcomb@va.gov', 'system'),
(4, 6, 'Shane.Ottinger@va.gov', 'system'),
(5, 6, 'Sulgeiry.Gardner@va.gov', 'system'),
(6, 6, 'Carrie.Hanscom@va.gov', 'system'),
(7, 6, 'Raphael.Fretter@va.gov', 'system'),
(8, 6, 'Michael.Shaffer1@va.gov', 'system'),
(9, 6, 'Juan.Rodriguez-Sanchez@va.gov', 'system'),
(10, 6, 'susan.schavee@va.gov', 'system'),
(11, 6, 'Amanda.TurnerSumner@va.gov', 'system'),
(12, 6, 'Max.Richard@va.gov', 'system');

-- --------------------------------------------------------

--
-- Table structure for table `employee_data_history`
--

CREATE TABLE IF NOT EXISTS `employee_data_history` (
  `empUID` mediumint(8) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  INDEX `empUID` (`empUID`,`indicatorID`),
  INDEX `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `indicatorID` (`indicatorID`,`categoryID`,`UID`)
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
(19, 'group', 11, 1, 1, 0),
(23, 'group', 1, 1, 1, 1),
(23, 'group', 2, 1, 0, 0),
(24, 'group', 1, 1, 1, 1),
(24, 'group', 2, 1, 0, 0),
(25, 'group', 1, 1, 1, 1),
(25, 'group', 2, 1, 0, 0),
(27, 'group', 2, 1, 0, 0),
(28, 'group', 2, 1, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `positions`
--

CREATE TABLE IF NOT EXISTS `positions` (
  `positionID` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `parentID` smallint(6) unsigned NOT NULL DEFAULT '0',
  `positionTitle` varchar(100) NOT NULL,
  `phoneticPositionTitle` varchar(100) NOT NULL DEFAULT '',
  `numberFTE` tinyint(3) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`positionID`),
  INDEX `positionTitle` (`positionTitle`),
  INDEX `numberFTE` (`numberFTE`),
  INDEX `parentID` (`parentID`),
  INDEX `phoneticPositionTitle` (`phoneticPositionTitle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  `positionID` smallint(6) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`positionID`,`indicatorID`),
  INDEX `indicatorID` (`indicatorID`)
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
  `positionID` smallint(6) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `data` text NOT NULL,
  `author` varchar(30) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  INDEX `timestamp` (`timestamp`),
  INDEX `positionID` (`positionID`,`indicatorID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `position_privileges`
--

CREATE TABLE IF NOT EXISTS `position_privileges` (
  `positionID` smallint(6) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` mediumint(8) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `positionID` (`positionID`,`categoryID`,`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `position_tags`
--

CREATE TABLE IF NOT EXISTS `position_tags` (
  `positionID` smallint(6) unsigned NOT NULL,
  `tag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  UNIQUE KEY `positionID` (`positionID`,`tag`),
  INDEX `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `relation_employee_backup`
--

CREATE TABLE IF NOT EXISTS `relation_employee_backup` (
  `empUID` mediumint(8) unsigned NOT NULL,
  `backupEmpUID` mediumint(8) unsigned NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT '0',
  `approverUserName` varchar(30) DEFAULT NULL,
  UNIQUE KEY `empUID` (`empUID`,`backupEmpUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `relation_group_employee`
--

CREATE TABLE IF NOT EXISTS `relation_group_employee` (
  `groupID` smallint(6) unsigned NOT NULL,
  `empUID` mediumint(8) unsigned NOT NULL,
  UNIQUE KEY `groupID_2` (`groupID`,`empUID`),
  INDEX `groupID` (`groupID`),
  INDEX `empUID` (`empUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `relation_group_employee`
--

INSERT INTO `relation_group_employee` (`groupID`, `empUID`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12);

-- --------------------------------------------------------

--
-- Table structure for table `relation_group_position`
--

CREATE TABLE IF NOT EXISTS `relation_group_position` (
  `groupID` smallint(6) unsigned NOT NULL,
  `positionID` smallint(6) unsigned NOT NULL,
  UNIQUE KEY `groupID_2` (`groupID`,`positionID`),
  INDEX `groupID` (`groupID`),
  INDEX `positionID` (`positionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `relation_position_employee`
--

CREATE TABLE IF NOT EXISTS `relation_position_employee` (
  `positionID` smallint(6) unsigned NOT NULL,
  `empUID` mediumint(8) unsigned NOT NULL,
  `isActing` TINYINT NOT NULL DEFAULT 0,
  UNIQUE KEY `positionID_2` (`positionID`,`empUID`),
  INDEX `positionID` (`positionID`),
  INDEX `empUID` (`empUID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE IF NOT EXISTS `sessions` (
  `sessionKey` varchar(40) NOT NULL,
  `variableKey` varchar(40) NOT NULL DEFAULT '',
  `data` text NOT NULL,
  `lastModified` int(10) unsigned NOT NULL,
  UNIQUE KEY `sessionKey` (`sessionKey`,`variableKey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE IF NOT EXISTS `settings` (
  `setting` varchar(30) NOT NULL,
  `data` varchar(50) NOT NULL,
  PRIMARY KEY (`setting`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`setting`, `data`) VALUES
('dbversion', '2020062600'),
('salt', rand()),
('version', '2743'),
('heading', 'Organizational Chart'),
('subheading', ''),
('timeZone', 'America/New_York'),
('adPath', ''),
('ERM_Sites', '{"resource_management":[]}');

-- --------------------------------------------------------

--
-- Table structure for table `tag_hierarchy`
--

CREATE TABLE IF NOT EXISTS `tag_hierarchy` (
  `tag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `parentTag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`tag`),
  INDEX `parentTag` (`parentTag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tag_hierarchy`
--

INSERT INTO `tag_hierarchy` (`tag`, `parentTag`) VALUES
('quadrad', NULL),
('service', 'quadrad');

SET SQL_SAFE_UPDATES=0;
UPDATE data_action_log dal,
	employee e
Set
	dal.userDisplay = concat(e.firstName, " " , e.lastName)
where dal.userID = e.empUID;
SET SQL_SAFE_UPDATES=1;

SET SQL_SAFE_UPDATES=0;
UPDATE `data_action_log`
	SET
	`timestamp` = CONVERT_TZ( timestamp, @@session.time_zone, '+00:00' );
SET SQL_SAFE_UPDATES = 1;
