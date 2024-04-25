SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `action_history`;
CREATE TABLE `action_history` (
  `actionID` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `recordID` mediumint unsigned NOT NULL,
  `userID` varchar(50) NOT NULL,
  `stepID` smallint NOT NULL DEFAULT '0',
  `dependencyID` smallint NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `actionTypeID` tinyint unsigned NOT NULL,
  `time` int unsigned NOT NULL,
  `comment` text,
  PRIMARY KEY (`actionID`),
  KEY `time` (`time`),
  KEY `recordID` (`recordID`),
  KEY `actionTypeID` (`actionTypeID`),
  KEY `dependencyID` (`dependencyID`),
  KEY `actionType` (`actionType`),
  CONSTRAINT `action_history_ibfk_2` FOREIGN KEY (`actionTypeID`) REFERENCES `action_types` (`actionTypeID`),
  CONSTRAINT `fk_records_action_history_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `action_types`;
CREATE TABLE `action_types` (
  `actionTypeID` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `actionTypeDesc` varchar(50) NOT NULL,
  PRIMARY KEY (`actionTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `action_types` (`actionTypeID`, `actionTypeDesc`) VALUES
(1,	'approved'),
(2,	'disapproved'),
(3,	'deferred'),
(4,	'deleted'),
(5,	'undeleted'),
(6,	'filled dependency'),
(7,	'unfilled dependency'),
(8,	'Generic');

DROP TABLE IF EXISTS `actions`;
CREATE TABLE `actions` (
  `actionType` varchar(50) NOT NULL,
  `actionText` varchar(50) NOT NULL,
  `actionTextPasttense` varchar(50) NOT NULL,
  `actionIcon` varchar(50) NOT NULL,
  `actionAlignment` varchar(20) NOT NULL,
  `sort` tinyint NOT NULL,
  `fillDependency` tinyint NOT NULL,
  `deleted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`actionType`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `actions` (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`, `deleted`) VALUES
('approve',	'Approve',	'Approved',	'gnome-emblem-default.svg',	'right',	0,	1,	0),
('concur',	'Concur',	'Concurred',	'go-next.svg',	'right',	1,	1,	0),
('defer',	'Defer',	'Deferred',	'software-update-urgent.svg',	'left',	0,	-2,	0),
('disapprove',	'Disapprove',	'Disapproved',	'process-stop.svg',	'left',	0,	-1,	0),
('sendback',	'Return to Requestor',	'Returned to Requestor',	'edit-undo.svg',	'left',	0,	0,	0),
('sign',	'Sign',	'Signed',	'application-certificate.svg',	'right',	0,	1,	0),
('submit',	'Submit',	'Submitted',	'gnome-emblem-default.svg',	'right',	0,	1,	0);

DROP TABLE IF EXISTS `approvals`;
CREATE TABLE `approvals` (
  `approvalID` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `recordID` mediumint unsigned NOT NULL,
  `userID` varchar(50) NOT NULL,
  `groupID` mediumint NOT NULL DEFAULT '0',
  `approvalType` varchar(50) NOT NULL,
  `time` int unsigned NOT NULL,
  `comment` text,
  PRIMARY KEY (`approvalID`),
  KEY `time` (`time`),
  KEY `recordID` (`recordID`),
  KEY `groupID` (`groupID`),
  KEY `record_group` (`recordID`,`groupID`),
  KEY `record_time` (`recordID`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `categoryID` varchar(20) NOT NULL,
  `parentID` varchar(50) NOT NULL,
  `categoryName` varchar(50) NOT NULL,
  `categoryDescription` varchar(255) NOT NULL,
  `workflowID` smallint NOT NULL,
  `sort` tinyint NOT NULL DEFAULT '0',
  `needToKnow` tinyint NOT NULL DEFAULT '0',
  `formLibraryID` smallint DEFAULT NULL,
  `visible` tinyint NOT NULL DEFAULT '1',
  `disabled` tinyint NOT NULL DEFAULT '0',
  `type` varchar(50) NOT NULL DEFAULT '',
  `destructionAge` mediumint unsigned DEFAULT NULL,
  `lastModified` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`categoryID`),
  KEY `parentID` (`parentID`),
  KEY `destructionAge` (`destructionAge`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `categories` (`categoryID`, `parentID`, `categoryName`, `categoryDescription`, `workflowID`, `sort`, `needToKnow`, `formLibraryID`, `visible`, `disabled`, `type`, `destructionAge`, `lastModified`) VALUES
('leaf_devconsole',	'',	'LEAF Developer Console',	'',	-2,	0,	0,	NULL,	1,	0,	'',	NULL,	0),
('leaf_secure',	'',	'Leaf Secure Certification',	'',	-1,	0,	0,	NULL,	1,	0,	'',	NULL,	0);

DROP TABLE IF EXISTS `category_count`;
CREATE TABLE `category_count` (
  `recordID` mediumint unsigned NOT NULL,
  `categoryID` varchar(20) NOT NULL,
  `count` tinyint unsigned NOT NULL,
  PRIMARY KEY (`recordID`,`categoryID`),
  KEY `categoryID` (`categoryID`),
  CONSTRAINT `category_count_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`),
  CONSTRAINT `fk_records_category_count_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `category_privs`;
CREATE TABLE `category_privs` (
  `categoryID` varchar(20) NOT NULL,
  `groupID` mediumint NOT NULL,
  `readable` tinyint NOT NULL,
  `writable` tinyint NOT NULL,
  UNIQUE KEY `categoryID` (`categoryID`,`groupID`),
  KEY `groupID` (`groupID`),
  CONSTRAINT `category_privs_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `category_staples`;
CREATE TABLE `category_staples` (
  `categoryID` varchar(20) NOT NULL,
  `stapledCategoryID` varchar(20) NOT NULL,
  UNIQUE KEY `category_stapled` (`categoryID`,`stapledCategoryID`),
  KEY `categoryID` (`categoryID`),
  CONSTRAINT `category_staples_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `data`;
CREATE TABLE `data` (
  `recordID` mediumint unsigned NOT NULL,
  `indicatorID` smallint NOT NULL,
  `series` tinyint unsigned NOT NULL DEFAULT '1',
  `data` text NOT NULL,
  `timestamp` int unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL,
  UNIQUE KEY `unique` (`recordID`,`indicatorID`,`series`),
  KEY `indicator_series` (`indicatorID`,`series`),
  KEY `fastdata` (`indicatorID`,`data`(10)),
  FULLTEXT KEY `data` (`data`),
  CONSTRAINT `fk_records_data_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `data_action_log`;
CREATE TABLE `data_action_log` (
  `empUID` varchar(36) DEFAULT NULL,
  `id` int NOT NULL AUTO_INCREMENT,
  `action` varchar(45) DEFAULT NULL,
  `userID` int DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `userDisplay` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `data_cache`;
CREATE TABLE `data_cache` (
  `cacheKey` varchar(32) NOT NULL,
  `data` text NOT NULL,
  `timestamp` int NOT NULL,
  UNIQUE KEY `cacheKey` (`cacheKey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `data_extended`;
CREATE TABLE `data_extended` (
  `recordID` mediumint unsigned NOT NULL,
  `indicatorID` smallint NOT NULL,
  `data` text NOT NULL,
  `timestamp` int unsigned NOT NULL,
  `userID` varchar(50) NOT NULL,
  KEY `recordID_indicatorID` (`recordID`,`indicatorID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `data_history`;
CREATE TABLE `data_history` (
  `recordID` mediumint unsigned NOT NULL,
  `indicatorID` smallint NOT NULL,
  `series` tinyint unsigned NOT NULL DEFAULT '1',
  `data` text NOT NULL,
  `timestamp` int unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL,
  KEY `recordID` (`recordID`,`indicatorID`,`series`),
  KEY `timestamp` (`timestamp`),
  CONSTRAINT `fk_records_data_history_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `data_log_items`;
CREATE TABLE `data_log_items` (
  `data_action_log_fk` int NOT NULL,
  `tableName` varchar(75) NOT NULL,
  `column` varchar(75) NOT NULL,
  `value` text NOT NULL,
  `displayValue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`data_action_log_fk`,`tableName`,`column`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `dependencies`;
CREATE TABLE `dependencies` (
  `dependencyID` smallint NOT NULL AUTO_INCREMENT,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`dependencyID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `dependencies` (`dependencyID`, `description`) VALUES
(-3,	'Group Designated by the Requestor'),
(-2,	'Requestor Followup'),
(-1,	'Person Designated by the Requestor'),
(1,	'Service Chief'),
(5,	'Request Submitted'),
(8,	'Quadrad');

DROP TABLE IF EXISTS `dependency_privs`;
CREATE TABLE `dependency_privs` (
  `dependencyID` smallint NOT NULL,
  `groupID` mediumint NOT NULL,
  UNIQUE KEY `dependencyID` (`dependencyID`,`groupID`),
  KEY `groupID` (`groupID`),
  CONSTRAINT `fk_privs_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies` (`dependencyID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `destruction_log`;
CREATE TABLE `destruction_log` (
  `recordID` mediumint unsigned NOT NULL,
  `categoryID` varchar(20) NOT NULL,
  `destructionTime` int unsigned DEFAULT '0',
  PRIMARY KEY (`recordID`),
  KEY `destructionTime` (`destructionTime`),
  KEY `destructionForm` (`categoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `email_reminders`;
CREATE TABLE `email_reminders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workflowID` smallint NOT NULL,
  `stepID` smallint NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `frequency` smallint NOT NULL,
  `recipientGroupID` mediumint NOT NULL,
  `emailTemplate` text NOT NULL,
  `startDateIndicatorID` smallint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `routeID` (`workflowID`,`stepID`,`actionType`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `email_templates`;
CREATE TABLE `email_templates` (
  `emailTemplateID` mediumint NOT NULL AUTO_INCREMENT,
  `label` varchar(255) NOT NULL,
  `emailTo` text,
  `emailCc` text,
  `subject` text NOT NULL,
  `body` text NOT NULL,
  PRIMARY KEY (`emailTemplateID`),
  UNIQUE KEY `label` (`label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `email_templates` (`emailTemplateID`, `label`, `emailTo`, `emailCc`, `subject`, `body`) VALUES
(-5,	'Automated Email Reminder',	'LEAF_automated_reminder_emailTo.tpl',	'LEAF_automated_reminder_emailCc.tpl',	'LEAF_automated_reminder_subject.tpl',	'LEAF_automated_reminder_body.tpl'),
(-4,	'Mass Action Email Reminder Template',	'LEAF_mass_action_remind_emailTo.tpl',	'LEAF_mass_action_remind_emailCc.tpl',	'LEAF_mass_action_remind_subject.tpl',	'LEAF_mass_action_remind_body.tpl'),
(-3,	'Notify Requestor of Completion',	'LEAF_notify_complete_emailTo.tpl',	'LEAF_notify_complete_emailCc.tpl',	'LEAF_notify_complete_subject.tpl',	'LEAF_notify_complete_body.tpl'),
(-2,	'Notify Next Approver',	'LEAF_notify_next_emailTo.tpl',	'LEAF_notify_next_emailCc.tpl',	'LEAF_notify_next_subject.tpl',	'LEAF_notify_next_body.tpl'),
(-1,	'Send Back',	'LEAF_send_back_emailTo.tpl',	'LEAF_send_back_emailCc.tpl',	'LEAF_send_back_subject.tpl',	'LEAF_send_back_body.tpl'),
(1,	'Default Email Template',	'',	'',	'',	'LEAF_main_email_template.tpl');

DROP TABLE IF EXISTS `email_tracker`;
CREATE TABLE `email_tracker` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recordID` mediumint unsigned NOT NULL,
  `userID` varchar(50) DEFAULT NULL,
  `timestamp` int NOT NULL,
  `recipients` text NOT NULL,
  `subject` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `recordID` (`recordID`),
  CONSTRAINT `fk_records_email_tracker_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `events`;
CREATE TABLE `events` (
  `eventID` varchar(40) NOT NULL,
  `eventDescription` varchar(200) NOT NULL,
  `eventType` varchar(40) NOT NULL,
  `eventData` text NOT NULL,
  PRIMARY KEY (`eventID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `events` (`eventID`, `eventDescription`, `eventType`, `eventData`) VALUES
('LeafSecure_Certified',	'Marks site as LEAF Secure',	'',	''),
('LeafSecure_DeveloperConsole',	'Grants developer console access',	'',	''),
('std_email_notify_completed',	'Notify the requestor',	'Email',	''),
('std_email_notify_next_approver',	'Notify the next approver',	'Email',	'');

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `groupID` mediumint NOT NULL AUTO_INCREMENT,
  `parentGroupID` mediumint DEFAULT NULL,
  `name` varchar(250) NOT NULL,
  `groupDescription` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`groupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `groups` (`groupID`, `parentGroupID`, `name`, `groupDescription`) VALUES
(-1,	NULL,	'Quadrad',	''),
(1,	NULL,	'sysadmin',	'');

DROP TABLE IF EXISTS `indicator_mask`;
CREATE TABLE `indicator_mask` (
  `indicatorID` smallint NOT NULL,
  `groupID` mediumint NOT NULL,
  UNIQUE KEY `indicatorID_2` (`indicatorID`,`groupID`),
  KEY `indicatorID` (`indicatorID`),
  KEY `groupID` (`groupID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `indicators`;
CREATE TABLE `indicators` (
  `indicatorID` smallint NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `format` text NOT NULL,
  `description` varchar(50) DEFAULT NULL,
  `default` text,
  `parentID` smallint DEFAULT NULL,
  `categoryID` varchar(20) DEFAULT NULL,
  `html` text,
  `htmlPrint` text,
  `conditions` text,
  `jsSort` varchar(255) DEFAULT NULL,
  `required` tinyint NOT NULL DEFAULT '0',
  `sort` tinyint NOT NULL DEFAULT '1',
  `timeAdded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `disabled` int unsigned NOT NULL DEFAULT '0',
  `is_sensitive` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`indicatorID`),
  KEY `categoryID` (`categoryID`),
  KEY `parentID` (`parentID`),
  KEY `sort` (`sort`),
  CONSTRAINT `indicators_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `htmlPrint`, `conditions`, `jsSort`, `required`, `sort`, `timeAdded`, `disabled`, `is_sensitive`) VALUES
(-8,	'Approval Officials',	'',	NULL,	NULL,	NULL,	'leaf_devconsole',	NULL,	NULL,	NULL,	NULL,	0,	2,	'2019-12-13 17:09:58',	0,	0),
(-7,	'Area Manager / Facility Chief Information Officer',	'orgchart_employee',	NULL,	NULL,	-8,	'leaf_devconsole',	NULL,	NULL,	NULL,	NULL,	1,	2,	'2019-12-13 17:08:23',	1,	0),
(-6,	'Supervisor',	'orgchart_employee',	NULL,	NULL,	-8,	'leaf_devconsole',	NULL,	NULL,	NULL,	NULL,	1,	1,	'2019-12-13 17:08:23',	0,	0),
(-5,	'LEAF Developer Console Overview',	'raw_data',	'',	NULL,	NULL,	'leaf_devconsole',	'<script>\r\n$(function() {\r\n\r\n\r\nif($(\'#{{ iID }}\').val() == \'Accepted terms and rules of behavior\') {\r\n    $(\'#rob_acceptance\').prop(\'checked\', true);\r\n}\r\nelse {\r\n    $(\'#{{ iID }}\').val($(\'#rob_acceptance\').val());\r\n}\r\n\r\n});\r\nformRequired[\"id-5\"] = {\r\n    setRequired: function() {\r\n        return ($(\'#rob_acceptance\').prop(\'checked\') == false);\r\n    }\r\n};\r\n</script>\r\n<p><b>This is a request to access the LEAF Developer Console.</b></p>\r\n<p>Approved individuals will gain the ability to modify LEAF\'s user interface using HTML, CSS, and JavaScript technologies.</p>\r\n<p>Please review the following:\r\n<ul>\r\n    <li>I validate that I have the technical ability to work with HTML, CSS, and JavaScript source code.</li>\r\n    <li>I recognize that source code customizations and their maintenance are the responsibility of the office seeking to make customizations. In the event that the responsible office becomes unable to support maintenance, customizations may be easily removed to restore standard functionality.</li>\r\n</ul>\r\n</p>\r\n\r\n<div id=\"rob\" style=\"border: 1px solid black; padding: 4px; background-color: white; height: 26em; overflow-y: auto\">\r\n    <h3>Department of Veterans Affairs (VA) National Rules of Behavior</h3>\r\n    <p>I understand, accept, and agree to the following terms and conditions that apply to my access to, and use of, information, including VA sensitive information, or information systems of the U.S. Department of Veterans Affairs.</p>\r\n    <ol type=\"1\">\r\n        <li>GENERAL RULES OF BEHAVIOR\r\n            <ol type=\"a\">\r\n                <li>I understand that when I use any Government information system, I have NO expectation of Privacy in VA records that I create or in my activities while accessing or using such information system.</li>\r\n                <li>I understand that authorized VA personnel may review my conduct or actions concerning VA information and information systems, and take appropriate action.  Authorized VA personnel include my supervisory chain of command as well as VA system administrators and Information Security Officers (ISOs).  Appropriate action may include monitoring, recording, copying, inspecting, restricting access, blocking, tracking, and disclosing information to authorized Office of Inspector General (OIG), VA, and law enforcement personnel.</li>\r\n                <li>I understand that the following actions are prohibited: unauthorized access, unauthorized uploading, unauthorized downloading, unauthorized changing, unauthorized circumventing, or unauthorized deleting information on VA systems, modifying VA systems, unauthorized denying or granting access to VA systems, using VA resources for unauthorized use on VA systems, or otherwise misusing VA systems or resources.  I also understand that attempting to engage in any of these unauthorized actions is also prohibited.</li>\r\n                <li>I understand that such unauthorized attempts or acts may result in disciplinary or other adverse action, as well as criminal, civil, and/or administrative penalties.  Depending on the severity of the violation, disciplinary or adverse action consequences may include: suspension of access privileges, reprimand, suspension from work, demotion, or removal.  Theft, conversion, or unauthorized disposal or destruction of Federal property or information may also result in criminal sanctions.</li>\r\n                <li>I understand that I have a responsibility to report suspected or identified information security incidents (security and privacy) to my Operating Unit’s Information Security Officer (ISO), Privacy Officer (PO), and my supervisor as appropriate.</li>\r\n                <li>I understand that I have a duty to report information about actual or possible criminal violations involving VA programs, operations, facilities, contracts or information systems to my supervisor, any management official or directly to the OIG, including reporting to the OIG Hotline.  I also understand that I have a duty to immediately report to the OIG any possible criminal matters involving felonies, including crimes involving information systems.</li>\r\n                <li>I understand that the VA National Rules of Behavior do not and should not be relied upon to create any other right or benefit, substantive or procedural, enforceable by law, by a party to litigation with the United States Government.</li>\r\n                <li>I understand that the VA National Rules of Behavior do not supersede any local policies that provide higher levels of protection to VA’s information or information systems.  The VA National Rules of Behavior provide the minimal rules with which individual users must comply.</li>\r\n                <li><b>I understand that if I refuse to sign this VA National Rules of Behavior as required by VA policy, I will be denied access to VA information and information systems.  Any refusal to sign the VA National Rules of Behavior may have an adverse impact on my employment with the Department.</b></li>\r\n            </ol>\r\n        </li>\r\n        <li>SPECIFIC RULES OF BEHAVIOR.\r\n            <ol type=\"a\">\r\n                <li>I will follow established procedures for requesting access to any VA computer system and for notification to the VA supervisor and the ISO when the access is no longer needed.</li>\r\n                <li>I will follow established VA information security and privacy policies and procedures.</li>\r\n                <li>I will use only devices, systems, software, and data which I am authorized to use, including complying with any software licensing or copyright restrictions.  This includes downloads of software offered as free trials, shareware or public domain.</li>\r\n                <li>I will only use my access for authorized and official duties, and to only access data that is needed in the fulfillment of my duties except as provided for in VA Directive 6001, Limited Personal Use of Government Office Equipment Including Information Technology.  I also agree that I will not engage in any activities prohibited as stated in section 2c of VA Directive 6001.</li>\r\n                <li>I will secure VA sensitive information in all areas (at work and remotely) and in any form (e.g. digital, paper etc.), to include mobile media and devices that contain sensitive information, and I will follow the mandate that all VA sensitive information must be in a protected environment at all times or it must be encrypted (using FIPS 140-2 approved encryption).  If clarification is needed whether or not an environment is adequately protected, I will follow the guidance of the local Chief Information Officer (CIO).</li>\r\n                <li>I will properly dispose of VA sensitive information, either in hardcopy, softcopy or electronic format, in accordance with VA policy and procedures.</li>\r\n                <li>I will not attempt to override, circumvent or disable operational, technical, or management security controls unless expressly directed to do so in writing by authorized VA staff.</li>\r\n                <li>I will not attempt to alter the security configuration of government equipment unless authorized.  This includes operational, technical, or management security controls.</li>\r\n                <li>I will protect my verify codes and passwords from unauthorized use and disclosure and ensure I utilize only passwords that meet the VA minimum requirements for the systems that I am authorized to use and are contained in Appendix F of VA Handbook 6500.</li>\r\n                <li>I will not store any passwords/verify codes in any type of script file or cache on VAsystems.</li>\r\n                <li>I will ensure that I log off or lock any computer or console before walking away and will not allow another user to access that computer or console while I am logged on to it.</li>\r\n                <li>I will not misrepresent, obscure, suppress, or replace a user’s identity on the Internet or any VA electronic communication system.</li>\r\n                <li>I will not auto-forward e-mail messages to addresses outside the VA network.</li>\r\n                <li>I will comply with any directions from my supervisors, VA system administrators and information security officers concerning my access to, and use of, VA information and information systems or matters covered by these Rules.</li>\r\n                <li>I will ensure that any devices that I use to transmit, access, and store VA sensitive information outside of a VA protected environment will use FIPS 140-2 approved encryption (the translation of data into a form that is unintelligible without a deciphering mechanism).  This includes laptops, thumb drives, and other removable storage devices and storage media (CDs, DVDs, etc.).</li>\r\n                <li>I will obtain the approval of appropriate management officials before releasing VA information for public dissemination.</li>\r\n                <li>I will not host, set up, administer, or operate any type of Internet server on any VA network or attempt to connect any personal equipment to a VA network unless explicitly authorized in writing by my local CIO and I will ensure that all such activity is in compliance with Federal and VA policies.</li>\r\n                <li>I will not attempt to probe computer systems to exploit system controls or access VA sensitive data for any reason other than in the performance of official duties.  Authorized penetration testing must be approved in writing by the VA CIO.</li>\r\n                <li>I will protect Government property from theft, loss, destruction, or misuse.  I will follow VA policies and procedures for handling Federal Government IT equipment and will sign for items provided to me for my exclusive use and return them when no longer required for VA activities.</li>\r\n                <li>I will only use virus protection software, anti-spyware, and firewall/intrusion detection software authorized by the VA on VA equipment or on computer systems that are connected to any VA network.</li>\r\n                <li>If authorized, by waiver, to use my own personal equipment, I must use VA approved virus protection software, anti-spyware, and firewall/intrusion detection software and ensure the software is configured to meet VA configuration requirements.  My local CIO will confirm that the system meets VA configuration requirements prior to connection to VA’s network.</li>\r\n                <li>I will never swap or surrender VA hard drives or other storage devices to anyone other than an authorized OI&T employee at the time of system problems.</li>\r\n                <li>I will not disable or degrade software programs used by the VA that install security software updates to VA computer equipment, to computer equipment used to connect to VA information systems, or to create, store or use VA information.</li>\r\n                <li>I agree to allow examination by authorized OI&T personnel of any personal IT device [Other Equipment (OE)] that I have been granted permission to use, whether remotely or in any setting to access VA information or information systems or to create, store or use VA information.</li>\r\n                <li>I agree to have all equipment scanned by the appropriate facility IT Operations Service prior to connecting to the VA network if the equipment has not been connected to the VA network for a period of more than three weeks.</li>\r\n                <li>I will complete mandatory periodic security and privacy awareness training within designated timeframes, and complete any additional required training for the particular systems to which I require access.</li>\r\n                <li>I understand that if I must sign a non-VA entity’s Rules of Behavior to obtain access to information or information systems controlled by that non-VA entity, I still must comply with my responsibilities under the VA National Rules of Behavior when accessing or using VA information or information systems.  However, those Rules of Behavior apply to my access to or use of the non-VA entity’s information and information systems as a VA user.</li>\r\n                <li>I understand that remote access is allowed from other Federal government computers and systems to VA information systems, subject to the terms of VA and the host Federal agency’s policies.</li>\r\n                <li>I agree that I will directly connect to the VA network whenever possible.  If a direct connection to the VA network is not possible, then I will use VA-approved remote access software and services.  I must use VA-provided IT equipment for remote access when possible.  I may be permitted to use non–VA IT equipment [Other Equipment (OE)] only if a VA-CIO-approved waiver has been issued and the equipment is configured to follow all VA security policies and requirements.  I agree that VA OI&T officials may examine such devices, including an OE device operating under an approved waiver, at any time for proper configuration and unauthorized storage of VA sensitive information.</li>\r\n                <li>I agree that I will not have both a VA network connection and any kind of non-VA network connection (including a modem or phone line or wireless network card, etc.) physically connected to any computer at the same time unless the dual connection is explicitly authorized in writing by my local CIO.</li>\r\n                <li>I agree that I will not allow VA sensitive information to reside on non-VA systems or devices unless specifically designated and approved in advance by the appropriate VA official (supervisor), and a waiver has been issued by the VA’s CIO.  I agree that I will not access, transmit or store remotely any VA sensitive information that is not encrypted using VA approved encryption.</li>\r\n                <li>I will obtain my VA supervisor’s authorization, in writing, prior to transporting, transmitting, accessing, and using VA sensitive information outside of VA’s protected environment.</li>\r\n                <li>I will ensure that VA sensitive information, in any format, and devices, systems and/or software that contain such information or that I use to access VA sensitive information or information systems are adequately secured in remote locations, e.g., at home and during travel, and agree to periodic VA inspections of the devices, systems or software from which I conduct access from remote locations.  I agree that if I work from a remote location pursuant to an approved telework agreement with VA sensitive information that authorized OI&T personnel may periodically inspect the remote location for compliance with required security requirements.</li>\r\n                <li>I will protect sensitive information from unauthorized disclosure, use, modification, or destruction, including using encryption products approved and provided by the VA to protect sensitive data.</li>\r\n                <li>I will not store or transport any VA sensitive information on any portable storage media or device unless it is encrypted using VA approved encryption.</li>\r\n                <li>I will use VA-provided encryption to encrypt any e-mail, including attachments to the e-mail, that contains VA sensitive information before sending the e-mail.  I will not send any e-mail that contains VA sensitive information in an unencrypted form.  VA sensitive information includes personally identifiable information and protected health information.</li>\r\n                <li>I may be required to acknowledge or sign additional specific or unique rules of behavior in order to access or use specific VA systems.  I understand that those specific rules of behavior may include, but are not limited to, restrictions or prohibitions on limited personal use, special requirements for access or use of the data in that system, special requirements for the devices used to access that specific system, or special restrictions on interconnections between that system and other IT resources or systems.</li>\r\n            </ol>\r\n        </li>\r\n        <li>Acknowledgement and Acceptance\r\n            <ol type=\"a\">\r\n                <li>I acknowledge that I have received a copy of these Rules of Behavior.</li>\r\n                <li>I understand, accept and agree to comply with all terms and conditions of these Rules of Behavior.</li>\r\n            </ol>\r\n        </li>\r\n    </ol>\r\n</div>\r\n<div>\r\n<label class=\"checkable leaf_check\" for=\"rob_acceptance\" title=\"Rules of Behavior\">\r\n<input class=\"icheck leaf_check\" type=\"checkbox\" id=\"rob_acceptance\" value=\"Accepted terms and rules of behavior\" />\r\n<span class=\"leaf_check\"></span> I understand and accept. <span id=\"rob_required\" style=\"margin-left: 8px; color: red\">*&nbsp; Required</span>\r\n</label>\r\n</div>',	'<style>\r\n    #devconsole_description > p, #devconsole_description > ul > li {\r\n        font-size: 16px;\r\n    }\r\n</style>\r\n<div id=\"devconsole_description\">\r\n<p><b>This is a request to access the LEAF Developer Console.</b></p>\r\n<p>Approved individuals will gain the ability to modify LEAF\'s user interface using HTML, CSS, and JavaScript technologies.</p>\r\n<p>By approving this request:\r\n<ul>\r\n    <li>I validate that the person requesting access as the technical ability to work with HTML, CSS, and JavaScript source code.</li>\r\n    <li>I recognize that source code customizations and their maintenance are the responsibility of the office seeking to make customizations. In the event that the responsible office becomes unable to support maintenance, customizations may be easily removed to restore standard functionality.</li>\r\n</ul>\r\n</p>\r\n</div>',	NULL,	NULL,	0,	1,	'2019-12-13 17:01:00',	0,	0),
(-4,	'Supervisor or ELT (GS-13 or higher)',	'orgchart_employee',	NULL,	NULL,	-3,	'leaf_secure',	NULL,	NULL,	NULL,	NULL,	1,	1,	'2019-08-09 15:52:34',	0,	0),
(-3,	'Approval Officials',	'',	NULL,	NULL,	NULL,	'leaf_secure',	'',	NULL,	NULL,	NULL,	0,	1,	'2019-08-09 15:48:46',	0,	0),
(-2,	'Justification for collection of sensitive data',	'textarea',	'',	'',	NULL,	'leaf_secure',	'<div id=\"leafSecureDialogContent\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContent\');\n\n});\n</script>',	'<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\"></script>\n<script>\n$(function() {\n\n    LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n});\n</script>',	NULL,	NULL,	1,	2,	'2019-07-30 20:25:06',	0,	0),
(-1,	'Privacy Officer',	'orgchart_employee',	NULL,	NULL,	-3,	'leaf_secure',	NULL,	NULL,	NULL,	NULL,	1,	1,	'2019-07-30 17:11:38',	0,	0);

DROP TABLE IF EXISTS `notes`;
CREATE TABLE `notes` (
  `noteID` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `recordID` mediumint unsigned NOT NULL,
  `note` text NOT NULL,
  `timestamp` int unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL,
  `deleted` tinyint DEFAULT NULL,
  PRIMARY KEY (`noteID`),
  KEY `recordID` (`recordID`),
  CONSTRAINT `fk_records_notes_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `process_query`;
CREATE TABLE `process_query` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userID` varchar(50) DEFAULT NULL,
  `url` text,
  `lastProcess` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `lastProcess` (`lastProcess`),
  FULLTEXT KEY `url` (`url`),
  FULLTEXT KEY `userid_url` (`userID`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `records`;
CREATE TABLE `records` (
  `recordID` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `date` int unsigned NOT NULL,
  `serviceID` smallint NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL,
  `title` text,
  `priority` tinyint NOT NULL DEFAULT '0',
  `lastStatus` varchar(200) DEFAULT NULL,
  `submitted` int NOT NULL DEFAULT '0',
  `deleted` int NOT NULL DEFAULT '0',
  `isWritableUser` tinyint unsigned NOT NULL DEFAULT '1',
  `isWritableGroup` tinyint unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`recordID`),
  KEY `date` (`date`),
  KEY `deleted` (`deleted`),
  KEY `serviceID` (`serviceID`),
  KEY `userID` (`userID`),
  KEY `submitted` (`submitted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `records_dependencies`;
CREATE TABLE `records_dependencies` (
  `recordID` mediumint unsigned NOT NULL,
  `dependencyID` smallint NOT NULL,
  `filled` tinyint NOT NULL DEFAULT '0',
  `time` int unsigned DEFAULT NULL,
  UNIQUE KEY `recordID` (`recordID`,`dependencyID`),
  KEY `filled` (`dependencyID`,`filled`),
  KEY `time` (`time`),
  CONSTRAINT `fk_records_dependencies_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE,
  CONSTRAINT `fk_records_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies` (`dependencyID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `records_step_fulfillment`;
CREATE TABLE `records_step_fulfillment` (
  `recordID` mediumint unsigned NOT NULL,
  `stepID` smallint NOT NULL,
  `fulfillmentTime` int unsigned NOT NULL,
  UNIQUE KEY `recordID` (`recordID`,`stepID`) USING BTREE,
  CONSTRAINT `fk_records_step_fulfillment_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `records_workflow_state`;
CREATE TABLE `records_workflow_state` (
  `recordID` mediumint unsigned NOT NULL,
  `stepID` smallint NOT NULL,
  `blockingStepID` tinyint unsigned NOT NULL DEFAULT '0',
  `lastNotified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `initialNotificationSent` tinyint(1) DEFAULT '0',
  UNIQUE KEY `recordID` (`recordID`,`stepID`),
  KEY `idx_lastNotified` (`lastNotified`),
  CONSTRAINT `fk_records_workflow_state_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `route_events`;
CREATE TABLE `route_events` (
  `workflowID` smallint NOT NULL,
  `stepID` smallint NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `eventID` varchar(40) NOT NULL,
  UNIQUE KEY `workflowID_2` (`workflowID`,`stepID`,`actionType`,`eventID`),
  KEY `eventID` (`eventID`),
  KEY `workflowID` (`workflowID`,`stepID`,`actionType`),
  KEY `actionType` (`actionType`),
  CONSTRAINT `route_events_ibfk_1` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`),
  CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `route_events` (`workflowID`, `stepID`, `actionType`, `eventID`) VALUES
(-1,	-2,	'approve',	'LeafSecure_Certified'),
(-2,	-5,	'approve',	'LeafSecure_DeveloperConsole'),
(-2,	-4,	'approve',	'LeafSecure_DeveloperConsole'),
(-2,	-5,	'approve',	'std_email_notify_completed'),
(-2,	-4,	'approve',	'std_email_notify_completed'),
(-1,	-2,	'approve',	'std_email_notify_completed'),
(-2,	-1,	'submit',	'std_email_notify_next_approver'),
(-1,	-3,	'approve',	'std_email_notify_next_approver'),
(-1,	-1,	'submit',	'std_email_notify_next_approver');

DROP TABLE IF EXISTS `service_chiefs`;
CREATE TABLE `service_chiefs` (
  `serviceID` smallint NOT NULL,
  `userID` varchar(50) NOT NULL,
  `backupID` varchar(50) NOT NULL DEFAULT '',
  `locallyManaged` tinyint(1) DEFAULT '0',
  `active` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`userID`,`serviceID`,`backupID`),
  KEY `serviceID` (`serviceID`),
  KEY `userID` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `services`;
CREATE TABLE `services` (
  `serviceID` smallint NOT NULL AUTO_INCREMENT,
  `service` varchar(100) NOT NULL,
  `abbreviatedService` varchar(25) NOT NULL,
  `groupID` mediumint DEFAULT NULL,
  PRIMARY KEY (`serviceID`),
  KEY `groupID` (`groupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `sessionKey` varchar(40) NOT NULL,
  `variableKey` varchar(40) NOT NULL DEFAULT '',
  `data` text NOT NULL,
  `lastModified` int unsigned NOT NULL,
  UNIQUE KEY `sessionKey` (`sessionKey`,`variableKey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


SET NAMES utf8mb4;

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `setting` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`setting`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `settings` (`setting`, `data`) VALUES
('adPath',	'{}'),
('dbversion',	'2024022901'),
('emailBCC',	'{}'),
('emailCC',	'{}'),
('heading',	'New LEAF Site'),
('leafSecure',	'0'),
('national_linkedPrimary',	''),
('national_linkedSubordinateList',	''),
('requestLabel',	'Request'),
('sitemap_json',	'{\"buttons\":[]}'),
('siteType',	'standard'),
('subHeading',	''),
('timeZone',	'America/New_York'),
('version',	'PUBLIC');

DROP TABLE IF EXISTS `short_links`;
CREATE TABLE `short_links` (
  `shortID` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(20) NOT NULL,
  `hash` varchar(64) NOT NULL,
  `data` text NOT NULL,
  PRIMARY KEY (`shortID`),
  UNIQUE KEY `type_hash` (`type`,`hash`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `signatures`;
CREATE TABLE `signatures` (
  `signatureID` mediumint NOT NULL AUTO_INCREMENT,
  `signature` text NOT NULL,
  `recordID` mediumint unsigned NOT NULL,
  `stepID` smallint NOT NULL,
  `dependencyID` smallint NOT NULL,
  `message` longtext NOT NULL,
  `signerPublicKey` text NOT NULL,
  `userID` varchar(50) NOT NULL,
  `timestamp` int unsigned NOT NULL,
  PRIMARY KEY (`signatureID`),
  UNIQUE KEY `recordID_stepID_depID` (`recordID`,`stepID`,`dependencyID`),
  CONSTRAINT `fk_records_signatures_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `sites`;
CREATE TABLE `sites` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `launchpadID` mediumint unsigned NOT NULL,
  `site_type` varchar(8) NOT NULL,
  `site_path` varchar(250) NOT NULL,
  `site_uploads` varchar(250) DEFAULT NULL,
  `portal_database` varchar(250) DEFAULT NULL,
  `orgchart_path` varchar(250) DEFAULT NULL,
  `orgchart_database` varchar(250) DEFAULT NULL,
  `decommissionTimestamp` int DEFAULT '0',
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `site_path` (`site_path`),
  KEY `site_type` (`site_type`),
  KEY `launchpadID` (`launchpadID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `step_dependencies`;
CREATE TABLE `step_dependencies` (
  `stepID` smallint NOT NULL,
  `dependencyID` smallint NOT NULL,
  UNIQUE KEY `stepID` (`stepID`,`dependencyID`),
  KEY `dependencyID` (`dependencyID`),
  CONSTRAINT `fk_step_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies` (`dependencyID`),
  CONSTRAINT `step_dependencies_ibfk_3` FOREIGN KEY (`stepID`) REFERENCES `workflow_steps` (`stepID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `step_dependencies` (`stepID`, `dependencyID`) VALUES
(-4,	-1),
(-3,	-1),
(-2,	-1);

DROP TABLE IF EXISTS `step_modules`;
CREATE TABLE `step_modules` (
  `stepID` smallint NOT NULL,
  `moduleName` varchar(50) NOT NULL,
  `moduleConfig` text NOT NULL,
  UNIQUE KEY `stepID_moduleName` (`stepID`,`moduleName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags` (
  `recordID` mediumint unsigned NOT NULL,
  `tag` varchar(50) NOT NULL,
  `timestamp` int unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL,
  UNIQUE KEY `recordID` (`recordID`,`tag`),
  KEY `tag` (`tag`),
  CONSTRAINT `fk_records_tags_deletion` FOREIGN KEY (`recordID`) REFERENCES `records` (`recordID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `template_history_files`;
CREATE TABLE `template_history_files` (
  `file_id` int NOT NULL AUTO_INCREMENT,
  `file_parent_name` text,
  `file_name` text,
  `file_path` text,
  `file_size` mediumint DEFAULT NULL,
  `file_modify_by` text,
  `file_created` text,
  PRIMARY KEY (`file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `userID` varchar(50) NOT NULL,
  `groupID` mediumint NOT NULL,
  `backupID` varchar(50) NOT NULL DEFAULT '',
  `primary_admin` tinyint(1) NOT NULL DEFAULT '0',
  `locallyManaged` tinyint(1) DEFAULT '0',
  `active` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`userID`,`groupID`,`backupID`),
  KEY `groupID` (`groupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `workflow_routes`;
CREATE TABLE `workflow_routes` (
  `workflowID` smallint NOT NULL,
  `stepID` smallint NOT NULL,
  `nextStepID` smallint NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `displayConditional` text NOT NULL,
  UNIQUE KEY `workflowID` (`workflowID`,`stepID`,`actionType`),
  KEY `stepID` (`stepID`),
  KEY `actionType` (`actionType`),
  CONSTRAINT `workflow_routes_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows` (`workflowID`),
  CONSTRAINT `workflow_routes_ibfk_3` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`, `actionType`, `displayConditional`) VALUES
(-2,	-4,	0,	'approve',	''),
(-2,	-4,	0,	'sendback',	''),
(-1,	-3,	-2,	'approve',	''),
(-1,	-3,	0,	'sendback',	''),
(-1,	-2,	0,	'approve',	''),
(-1,	-2,	0,	'sendback',	'');

DROP TABLE IF EXISTS `workflow_steps`;
CREATE TABLE `workflow_steps` (
  `workflowID` smallint NOT NULL,
  `stepID` smallint NOT NULL AUTO_INCREMENT,
  `stepTitle` varchar(64) NOT NULL,
  `stepBgColor` varchar(10) NOT NULL DEFAULT '#fffdcd',
  `stepFontColor` varchar(10) NOT NULL DEFAULT 'black',
  `stepBorder` varchar(20) NOT NULL DEFAULT '1px solid black',
  `jsSrc` varchar(128) NOT NULL,
  `posX` smallint DEFAULT NULL,
  `posY` smallint DEFAULT NULL,
  `indicatorID_for_assigned_empUID` smallint DEFAULT NULL,
  `indicatorID_for_assigned_groupID` smallint DEFAULT NULL,
  `requiresDigitalSignature` tinyint(1) DEFAULT NULL,
  `stepData` text,
  PRIMARY KEY (`stepID`),
  KEY `workflowID` (`workflowID`),
  CONSTRAINT `workflow_steps_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows` (`workflowID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `workflow_steps` (`workflowID`, `stepID`, `stepTitle`, `stepBgColor`, `stepFontColor`, `stepBorder`, `jsSrc`, `posX`, `posY`, `indicatorID_for_assigned_empUID`, `indicatorID_for_assigned_groupID`, `requiresDigitalSignature`, `stepData`) VALUES
(-2,	-4,	'Supervisory Review for LEAF Developer Console',	'#82b9fe',	'black',	'1px solid black',	'',	580,	146,	-6,	NULL,	NULL,	NULL),
(-1,	-3,	'Supervisory Review for LEAF-S Certification',	'#82b9fe',	'black',	'1px solid black',	'',	579,	146,	-4,	NULL,	NULL,	NULL),
(-1,	-2,	'Privacy Officer Review for LEAF-S Certification',	'#82b9fe',	'black',	'1px solid black',	'',	575,	331,	-1,	NULL,	NULL,	NULL);

DROP TABLE IF EXISTS `workflows`;
CREATE TABLE `workflows` (
  `workflowID` smallint NOT NULL AUTO_INCREMENT,
  `initialStepID` smallint NOT NULL DEFAULT '0',
  `description` varchar(64) NOT NULL,
  PRIMARY KEY (`workflowID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `workflows` (`workflowID`, `initialStepID`, `description`) VALUES
(-2,	-4,	'Leaf Developer Console'),
(-1,	-3,	'LEAF Secure Certification');
