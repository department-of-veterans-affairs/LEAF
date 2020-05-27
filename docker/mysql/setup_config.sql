SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
CREATE TABLE `orgchart_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NOT NULL,
  `url` varchar(512) NOT NULL,
  `database_name` varchar(512) NOT NULL,
  `path` varchar(512) NOT NULL,
  `launchpad_id` int(11) NOT NULL,
  `upload_directory` varchar(512) NOT NULL,
  `active_directory_path` varchar(512) NOT NULL,
  `leaf_secure` binary(1) NOT NULL,
  `title` varchar(512) NOT NULL,
  `city` varchar(512) NOT NULL,
  `adminLogonName` varchar(512) NOT NULL,
  `libs_path` varchar(512) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `database_name` (`database_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;


CREATE TABLE `portal_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NOT NULL,
  `url` varchar(512) NOT NULL,
  `database_name` varchar(512) NOT NULL,
  `path` varchar(512) NOT NULL,
  `launchpad_id` int(11) NOT NULL,
  `upload_directory` varchar(512) NOT NULL,
  `active_directory_path` varchar(512) NOT NULL,
  `leaf_secure` binary(1) NOT NULL,
  `title` varchar(512) NOT NULL,
  `city` varchar(512) NOT NULL,
  `adminLogonName` varchar(512) NOT NULL,
  `libs_path` varchar(512) NOT NULL,
  `descriptionID` int(11) NOT NULL,
  `emailPrefix` varchar(512) NOT NULL,
  `emailCC` varchar(512) NOT NULL,
  `emailBCC` varchar(512) NOT NULL,
  `orgchart_id` int(11) NOT NULL,
  `orgchart_tags` varchar(512) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;