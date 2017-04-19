START TRANSACTION;
CREATE TABLE IF NOT EXISTS `indicator_privileges` (
  `indicatorID` smallint(5) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` smallint(5) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `indicatorID` (`indicatorID`,`categoryID`,`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `indicators` ADD `encrypted` TINYINT( 1 ) NOT NULL DEFAULT '0' AFTER `timeAdded`;

TRUNCATE TABLE `groups`;
TRUNCATE TABLE `group_data`;
TRUNCATE TABLE `group_data_history`;
TRUNCATE TABLE `group_tags`;
TRUNCATE TABLE `relation_group_employee`;
TRUNCATE TABLE `relation_group_position`;

CREATE TABLE IF NOT EXISTS `groups` (
  `groupID` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `parentID` smallint(5) unsigned NOT NULL DEFAULT '0',
  `groupTitle` varchar(250) NOT NULL,
  `groupAbbreviation` varchar(20) DEFAULT NULL,
  `phoneticGroupTitle` varchar(250) NOT NULL DEFAULT '',
  PRIMARY KEY (`groupID`),
  KEY `parentID` (`parentID`),
  KEY `groupAbbreviation` (`groupAbbreviation`),
  KEY `groupTitle` (`groupTitle`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=11 ;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`groupID`, `parentID`, `groupTitle`, `groupAbbreviation`, `phoneticGroupTitle`) VALUES
(1, 0, 'System Administrators', NULL, 'SSTMTMNSTRTRS'),
(2, 0, 'Everyone', NULL, 'EFRYN'),
(3, 0, 'System Reserved.1', NULL, 'SSTMRSRFT'),
(4, 0, 'System Reserved.2', NULL, 'SSTMRSRFT'),
(5, 0, 'System Reserved.3', NULL, 'SSTMRSRFT'),
(6, 0, 'System Reserved.4', NULL, 'SSTMRSRFT'),
(7, 0, 'System Reserved.5', NULL, 'SSTMRSRFT'),
(8, 0, 'System Reserved.6', NULL, 'SSTMRSRFT'),
(9, 0, 'System Reserved.7', NULL, 'SSTMRSRFT'),
(10, 0, 'System Reserved.8', NULL, 'SSTMRSRFT');

CREATE TABLE IF NOT EXISTS `group_privileges` (
  `groupID` smallint(5) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` smallint(5) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `groupID` (`groupID`,`categoryID`,`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `position_privileges` (
  `positionID` smallint(5) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` smallint(5) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `positionID` (`positionID`,`categoryID`,`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `employee_privileges` (
  `empUID` smallint(5) unsigned NOT NULL,
  `categoryID` enum('employee','position','group') NOT NULL,
  `UID` smallint(5) unsigned NOT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `write` tinyint(1) NOT NULL DEFAULT '0',
  `grant` tinyint(1) NOT NULL DEFAULT '0',
  UNIQUE KEY `empUID` (`empUID`,`categoryID`,`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE `settings` SET `data` = '2737' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
