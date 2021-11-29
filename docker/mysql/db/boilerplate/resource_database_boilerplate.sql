SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `leaf_data`
--

-- --------------------------------------------------------

--
-- Table structure for table `actions`
--

CREATE TABLE `actions` (
  `actionType` varchar(50) NOT NULL,
  `actionText` varchar(50) NOT NULL,
  `actionTextPasttense` varchar(50) NOT NULL,
  `actionIcon` varchar(50) NOT NULL,
  `actionAlignment` varchar(20) NOT NULL,
  `sort` tinyint(4) NOT NULL,
  `fillDependency` tinyint(4) NOT NULL,
  `deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `actions`
--

INSERT INTO `actions` (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`, `deleted`) VALUES
('approve', 'Approve', 'Approved', 'gnome-emblem-default.svg', 'right', 0, 1, 0),
('concur', 'Concur', 'Concurred', 'go-next.svg', 'right', 1, 1, 0),
('defer', 'Defer', 'Deferred', 'software-update-urgent.svg', 'left', 0, -2, 0),
('disapprove', 'Disapprove', 'Disapproved', 'process-stop.svg', 'left', 0, -1, 0),
('sendback', 'Return to Requestor', 'Returned to Requestor', 'edit-undo.svg', 'left', 0, 0, 0),
('sign', 'Sign', 'Signed', 'application-certificate.svg', 'right', 0, 1, 0),
('submit', 'Submit', 'Submitted', 'gnome-emblem-default.svg', 'right', 0, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `action_history`
--

CREATE TABLE `action_history` (
  `actionID` mediumint(8) UNSIGNED NOT NULL,
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `userID` varchar(50) NOT NULL,
  `stepID` smallint(6) NOT NULL DEFAULT 0,
  `dependencyID` smallint(6) NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `actionTypeID` tinyint(3) UNSIGNED NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `comment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `action_types`
--

CREATE TABLE `action_types` (
  `actionTypeID` tinyint(3) UNSIGNED NOT NULL,
  `actionTypeDesc` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `action_types`
--

INSERT INTO `action_types` (`actionTypeID`, `actionTypeDesc`) VALUES
(1, 'approved'),
(2, 'disapproved'),
(3, 'deferred'),
(4, 'deleted'),
(5, 'undeleted'),
(6, 'filled dependency'),
(7, 'unfilled dependency'),
(8, 'Generic');

-- --------------------------------------------------------

--
-- Table structure for table `approvals`
--

CREATE TABLE `approvals` (
  `approvalID` mediumint(8) UNSIGNED NOT NULL,
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `userID` varchar(50) NOT NULL,
  `groupID` mediumint(9) NOT NULL DEFAULT 0,
  `approvalType` varchar(50) NOT NULL,
  `time` int(10) UNSIGNED NOT NULL,
  `comment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `categoryID` varchar(20) NOT NULL,
  `parentID` varchar(50) NOT NULL,
  `categoryName` varchar(50) NOT NULL,
  `categoryDescription` varchar(255) NOT NULL,
  `workflowID` smallint(6) NOT NULL,
  `sort` tinyint(3) NOT NULL DEFAULT 0,
  `needToKnow` tinyint(4) NOT NULL DEFAULT 0,
  `formLibraryID` smallint(6) DEFAULT NULL,
  `visible` tinyint(4) NOT NULL DEFAULT 1,
  `disabled` tinyint(4) NOT NULL DEFAULT 0,
  `type` varchar(50) NOT NULL DEFAULT '',
  `lastModified` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`categoryID`, `parentID`, `categoryName`, `categoryDescription`, `workflowID`, `sort`, `needToKnow`, `formLibraryID`, `visible`, `disabled`, `type`, `lastModified`) VALUES
('leaf_secure', '', 'Leaf Secure Certification', '', -1, 0, 0, NULL, 1, 0, '', 0);

-- --------------------------------------------------------

--
-- Table structure for table `category_count`
--

CREATE TABLE `category_count` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `categoryID` varchar(20) NOT NULL,
  `count` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `category_privs`
--

CREATE TABLE `category_privs` (
  `categoryID` varchar(20) NOT NULL,
  `groupID` mediumint(9) NOT NULL,
  `readable` tinyint(4) NOT NULL,
  `writable` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `category_staples`
--

CREATE TABLE `category_staples` (
  `categoryID` varchar(20) NOT NULL,
  `stapledCategoryID` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `data`
--

CREATE TABLE `data` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `series` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `data` text NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `data_cache`
--

CREATE TABLE `data_cache` (
  `cacheKey` varchar(32) NOT NULL,
  `data` text NOT NULL,
  `timestamp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `data_extended`
--

CREATE TABLE `data_extended` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `indicatorID` smallint(6) NOT NULL,
  `data` text NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL,
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `data_history`
--

CREATE TABLE `data_history` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `series` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `data` text NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dependencies`
--

CREATE TABLE `dependencies` (
  `dependencyID` smallint(6) NOT NULL,
  `description` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `dependencies`
--

INSERT INTO `dependencies` (`dependencyID`, `description`) VALUES
(-3, 'Group Designated by the Requestor'),
(-2, 'Requestor Followup'),
(-1, 'Person Designated by the Requestor'),
(1, 'Service Chief'),
(5, 'Request Submitted'),
(8, 'Quadrad');

-- --------------------------------------------------------

--
-- Table structure for table `dependency_privs`
--

CREATE TABLE `dependency_privs` (
  `dependencyID` smallint(6) NOT NULL,
  `groupID` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `eventID` varchar(40) NOT NULL,
  `eventDescription` varchar(200) NOT NULL,
  `eventData` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`eventID`, `eventDescription`, `eventData`) VALUES
('LeafSecure_Certified', 'Marks site as LEAF Secure', ''),
('std_email_notify_completed', 'Notify the requestor via email', ''),
('std_email_notify_next_approver', 'Notify the next approver via email', '');

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `groupID` mediumint(9) NOT NULL,
  `parentGroupID` tinyint(4) DEFAULT NULL,
  `name` varchar(250) NOT NULL,
  `groupDescription` varchar(50) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`groupID`, `parentGroupID`, `name`, `groupDescription`) VALUES
(-1, NULL, 'Quadrad', ''),
(1, NULL, 'sysadmin', '');

-- --------------------------------------------------------

--
-- Table structure for table `indicators`
--

CREATE TABLE `indicators` (
  `indicatorID` smallint(5) NOT NULL,
  `name` text NOT NULL,
  `format` text NOT NULL,
  `description` varchar(50) DEFAULT NULL,
  `default` text DEFAULT NULL,
  `parentID` smallint(6) DEFAULT NULL,
  `categoryID` varchar(20) DEFAULT NULL,
  `html` text DEFAULT NULL,
  `htmlPrint` text DEFAULT NULL,
  `jsSort` varchar(255) DEFAULT NULL,
  `required` tinyint(4) NOT NULL DEFAULT 0,
  `sort` tinyint(4) NOT NULL DEFAULT 1,
  `timeAdded` timestamp NOT NULL DEFAULT current_timestamp(),
  `disabled` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `is_sensitive` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `indicators`
--

INSERT INTO `indicators` (`indicatorID`, `name`, `format`, `description`, `default`, `parentID`, `categoryID`, `html`, `htmlPrint`, `jsSort`, `required`, `sort`, `timeAdded`, `disabled`, `is_sensitive`) VALUES
(-4, 'Supervisor or ELT (GS-13 or higher)', 'orgchart_employee', NULL, NULL, -3, 'leaf_secure', NULL, NULL, NULL, 1, 1, '2019-08-09 19:52:34', 0, 0),
(-3, 'Approval Officials', '', NULL, NULL, NULL, 'leaf_secure', '', NULL, NULL, 0, 1, '2019-08-09 19:48:46', 0, 0),
(-2, 'Justification for collection of sensitive data', 'textarea', '', '', NULL, 'leaf_secure', '<div id=\"leafSecureDialogContent\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\" />\n<script>\n$(function() {\n\n	LeafSecureReviewDialog(\'leafSecureDialogContent\');\n\n});\n</script>', '<div id=\"leafSecureDialogContentPrint\"></div>\n\n<script src=\"js/LeafSecureReviewDialog.js\" />\n<script>\n$(function() {\n\n	LeafSecureReviewDialog(\'leafSecureDialogContentPrint\');\n\n});\n</script>', NULL, 1, 2, '2019-07-31 00:25:06', 0, 0),
(-1, 'Privacy Officer', 'orgchart_employee', NULL, NULL, -3, 'leaf_secure', NULL, NULL, NULL, 1, 1, '2019-07-30 21:11:38', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `indicator_mask`
--

CREATE TABLE `indicator_mask` (
  `indicatorID` smallint(5) NOT NULL,
  `groupID` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `noteID` mediumint(8) UNSIGNED NOT NULL,
  `recordID` smallint(5) UNSIGNED NOT NULL,
  `note` text NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `userID` varchar(50) NOT NULL,
  `deleted` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records`
--

CREATE TABLE `records` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `date` int(10) UNSIGNED NOT NULL,
  `serviceID` smallint(5) NOT NULL DEFAULT 0,
  `userID` varchar(50) NOT NULL,
  `title` text DEFAULT NULL,
  `priority` tinyint(4) NOT NULL DEFAULT 0,
  `lastStatus` varchar(200) DEFAULT NULL,
  `submitted` int(10) NOT NULL DEFAULT 0,
  `deleted` int(10) NOT NULL DEFAULT 0,
  `isWritableUser` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `isWritableGroup` tinyint(3) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records_dependencies`
--

CREATE TABLE `records_dependencies` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `dependencyID` smallint(6) NOT NULL,
  `filled` tinyint(3) NOT NULL DEFAULT 0,
  `time` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records_step_fulfillment`
--

CREATE TABLE `records_step_fulfillment` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `fulfillmentTime` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records_workflow_state`
--

CREATE TABLE `records_workflow_state` (
  `recordID` mediumint(8) UNSIGNED NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `blockingStepID` tinyint(4) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `route_events`
--

CREATE TABLE `route_events` (
  `workflowID` smallint(6) NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `eventID` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `route_events`
--

INSERT INTO `route_events` (`workflowID`, `stepID`, `actionType`, `eventID`) VALUES
(-1, -3, 'approve', 'std_email_notify_next_approver'),
(-1, -2, 'approve', 'LeafSecure_Certified'),
(-1, -2, 'approve', 'std_email_notify_completed'),
(-1, -1, 'submit', 'std_email_notify_next_approver');

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE `services` (
  `serviceID` smallint(5) NOT NULL,
  `service` varchar(100) NOT NULL,
  `abbreviatedService` varchar(25) NOT NULL,
  `groupID` mediumint(9) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `service_chiefs`
--

CREATE TABLE `service_chiefs` (
  `serviceID` smallint(5) NOT NULL,
  `userID` varchar(50) NOT NULL,
  `locallyManaged` tinyint(1) DEFAULT 0,
  `active` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `sessionKey` varchar(40) NOT NULL,
  `variableKey` varchar(40) NOT NULL DEFAULT '',
  `data` text NOT NULL,
  `lastModified` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `setting` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`setting`, `data`) VALUES
('dbversion', '2019120500'),
('heading', ''),
('leafSecure', '0'),
('national_linkedPrimary', ''),
('national_linkedSubordinateList', ''),
('requestLabel', 'Request'),
('siteType', 'standard'),
('subHeading', ''),
('timeZone', 'America/New_York'),
('version', '2240');

-- --------------------------------------------------------

--
-- Table structure for table `short_links`
--

CREATE TABLE `short_links` (
  `shortID` mediumint(8) UNSIGNED NOT NULL,
  `type` varchar(20) NOT NULL,
  `hash` varchar(64) NOT NULL,
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `signatures`
--

CREATE TABLE `signatures` (
  `signatureID` mediumint(9) NOT NULL,
  `signature` text NOT NULL,
  `recordID` smallint(5) UNSIGNED NOT NULL,
  `stepID` smallint(5) NOT NULL,
  `dependencyID` smallint(5) NOT NULL,
  `message` longtext NOT NULL,
  `signerPublicKey` text NOT NULL,
  `userID` varchar(50) NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `step_dependencies`
--

CREATE TABLE `step_dependencies` (
  `stepID` smallint(6) NOT NULL,
  `dependencyID` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `step_dependencies`
--

INSERT INTO `step_dependencies` (`stepID`, `dependencyID`) VALUES
(-3, -1),
(-2, -1);

-- --------------------------------------------------------

--
-- Table structure for table `step_modules`
--

CREATE TABLE `step_modules` (
  `stepID` smallint(6) NOT NULL,
  `moduleName` varchar(50) NOT NULL,
  `moduleConfig` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

CREATE TABLE `tags` (
  `recordID` int(11) UNSIGNED NOT NULL,
  `tag` varchar(50) NOT NULL,
  `timestamp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userID` varchar(50) NOT NULL,
  `groupID` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `workflows`
--

CREATE TABLE `workflows` (
  `workflowID` smallint(6) NOT NULL,
  `initialStepID` smallint(6) NOT NULL DEFAULT 0,
  `description` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `workflows`
--

INSERT INTO `workflows` (`workflowID`, `initialStepID`, `description`) VALUES
(-1, -3, 'LEAF Secure Certification');

-- --------------------------------------------------------

--
-- Table structure for table `workflow_routes`
--

CREATE TABLE `workflow_routes` (
  `workflowID` smallint(6) NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `nextStepID` smallint(6) NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `displayConditional` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `workflow_routes`
--

INSERT INTO `workflow_routes` (`workflowID`, `stepID`, `nextStepID`, `actionType`, `displayConditional`) VALUES
(-1, -3, -2, 'approve', ''),
(-1, -3, 0, 'sendback', ''),
(-1, -2, 0, 'approve', ''),
(-1, -2, 0, 'sendback', '');

-- --------------------------------------------------------

--
-- Table structure for table `workflow_steps`
--

CREATE TABLE `workflow_steps` (
  `workflowID` smallint(6) NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `stepTitle` varchar(64) NOT NULL,
  `stepBgColor` varchar(10) NOT NULL DEFAULT '#fffdcd',
  `stepFontColor` varchar(10) NOT NULL DEFAULT 'black',
  `stepBorder` varchar(20) NOT NULL DEFAULT '1px solid black',
  `jsSrc` varchar(128) NOT NULL,
  `posX` smallint(6) DEFAULT NULL,
  `posY` smallint(6) DEFAULT NULL,
  `indicatorID_for_assigned_empUID` smallint(6) DEFAULT NULL,
  `indicatorID_for_assigned_groupID` smallint(6) DEFAULT NULL,
  `requiresDigitalSignature` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `workflow_steps`
--

INSERT INTO `workflow_steps` (`workflowID`, `stepID`, `stepTitle`, `stepBgColor`, `stepFontColor`, `stepBorder`, `jsSrc`, `posX`, `posY`, `indicatorID_for_assigned_empUID`, `indicatorID_for_assigned_groupID`, `requiresDigitalSignature`) VALUES
(-1, -3, 'Supervisory Review for LEAF-S Certification', '#82b9fe', 'black', '1px solid black', '', 579, 146, -4, NULL, NULL),
(-1, -2, 'Privacy Officer Review for LEAF-S Certification', '#82b9fe', 'black', '1px solid black', '', 575, 331, -1, NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `actions`
--
ALTER TABLE `actions`
  ADD PRIMARY KEY (`actionType`);

--
-- Indexes for table `action_history`
--
ALTER TABLE `action_history`
  ADD PRIMARY KEY (`actionID`),
  ADD KEY `time` (`time`),
  ADD KEY `recordID` (`recordID`),
  ADD KEY `actionTypeID` (`actionTypeID`),
  ADD KEY `dependencyID` (`dependencyID`),
  ADD KEY `actionType` (`actionType`);

--
-- Indexes for table `action_types`
--
ALTER TABLE `action_types`
  ADD PRIMARY KEY (`actionTypeID`);

--
-- Indexes for table `approvals`
--
ALTER TABLE `approvals`
  ADD PRIMARY KEY (`approvalID`),
  ADD KEY `time` (`time`),
  ADD KEY `recordID` (`recordID`),
  ADD KEY `groupID` (`groupID`),
  ADD KEY `record_group` (`recordID`,`groupID`),
  ADD KEY `record_time` (`recordID`,`time`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`categoryID`),
  ADD KEY `parentID` (`parentID`);

--
-- Indexes for table `category_count`
--
ALTER TABLE `category_count`
  ADD PRIMARY KEY (`recordID`,`categoryID`),
  ADD KEY `categoryID` (`categoryID`);

--
-- Indexes for table `category_privs`
--
ALTER TABLE `category_privs`
  ADD UNIQUE KEY `categoryID` (`categoryID`,`groupID`),
  ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `category_staples`
--
ALTER TABLE `category_staples`
  ADD UNIQUE KEY `category_stapled` (`categoryID`,`stapledCategoryID`),
  ADD KEY `categoryID` (`categoryID`);

--
-- Indexes for table `data`
--
ALTER TABLE `data`
  ADD UNIQUE KEY `unique` (`recordID`,`indicatorID`,`series`),
  ADD KEY `indicator_series` (`indicatorID`,`series`);

--
-- Indexes for table `data_cache`
--
ALTER TABLE `data_cache`
  ADD UNIQUE KEY `cacheKey` (`cacheKey`);

--
-- Indexes for table `data_extended`
--
ALTER TABLE `data_extended`
  ADD KEY `recordID_indicatorID` (`recordID`,`indicatorID`);

--
-- Indexes for table `data_history`
--
ALTER TABLE `data_history`
  ADD KEY `recordID` (`recordID`,`indicatorID`,`series`),
  ADD KEY `timestamp` (`timestamp`);

--
-- Indexes for table `dependencies`
--
ALTER TABLE `dependencies`
  ADD PRIMARY KEY (`dependencyID`);

--
-- Indexes for table `dependency_privs`
--
ALTER TABLE `dependency_privs`
  ADD UNIQUE KEY `dependencyID` (`dependencyID`,`groupID`),
  ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`eventID`);

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`groupID`);

--
-- Indexes for table `indicators`
--
ALTER TABLE `indicators`
  ADD PRIMARY KEY (`indicatorID`),
  ADD KEY `parentID` (`parentID`),
  ADD KEY `categoryID` (`categoryID`),
  ADD KEY `sort` (`sort`);

--
-- Indexes for table `indicator_mask`
--
ALTER TABLE `indicator_mask`
  ADD UNIQUE KEY `indicatorID_2` (`indicatorID`,`groupID`),
  ADD KEY `indicatorID` (`indicatorID`),
  ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`noteID`),
  ADD KEY `recordID` (`recordID`);

--
-- Indexes for table `records`
--
ALTER TABLE `records`
  ADD PRIMARY KEY (`recordID`),
  ADD KEY `date` (`date`),
  ADD KEY `deleted` (`deleted`),
  ADD KEY `serviceID` (`serviceID`);

--
-- Indexes for table `records_dependencies`
--
ALTER TABLE `records_dependencies`
  ADD UNIQUE KEY `recordID` (`recordID`,`dependencyID`),
  ADD KEY `filled` (`dependencyID`,`filled`),
  ADD KEY `time` (`time`);

--
-- Indexes for table `records_step_fulfillment`
--
ALTER TABLE `records_step_fulfillment`
  ADD UNIQUE KEY `recordID` (`recordID`,`stepID`) USING BTREE;

--
-- Indexes for table `records_workflow_state`
--
ALTER TABLE `records_workflow_state`
  ADD UNIQUE KEY `recordID` (`recordID`,`stepID`);

--
-- Indexes for table `route_events`
--
ALTER TABLE `route_events`
  ADD UNIQUE KEY `workflowID_2` (`workflowID`,`stepID`,`actionType`,`eventID`),
  ADD KEY `eventID` (`eventID`),
  ADD KEY `workflowID` (`workflowID`,`stepID`,`actionType`),
  ADD KEY `actionType` (`actionType`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`serviceID`),
  ADD UNIQUE KEY `service` (`service`),
  ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `service_chiefs`
--
ALTER TABLE `service_chiefs`
  ADD UNIQUE KEY `serviceID_2` (`serviceID`,`userID`),
  ADD KEY `serviceID` (`serviceID`),
  ADD KEY `userID` (`userID`);

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
-- Indexes for table `short_links`
--
ALTER TABLE `short_links`
  ADD PRIMARY KEY (`shortID`),
  ADD UNIQUE KEY `type_hash` (`type`,`hash`);

--
-- Indexes for table `signatures`
--
ALTER TABLE `signatures`
  ADD PRIMARY KEY (`signatureID`),
  ADD UNIQUE KEY `recordID_stepID_depID` (`recordID`,`stepID`,`dependencyID`);

--
-- Indexes for table `step_dependencies`
--
ALTER TABLE `step_dependencies`
  ADD UNIQUE KEY `stepID` (`stepID`,`dependencyID`),
  ADD KEY `dependencyID` (`dependencyID`);

--
-- Indexes for table `step_modules`
--
ALTER TABLE `step_modules`
  ADD UNIQUE KEY `stepID_moduleName` (`stepID`,`moduleName`);

--
-- Indexes for table `tags`
--
ALTER TABLE `tags`
  ADD UNIQUE KEY `recordID` (`recordID`,`tag`),
  ADD KEY `tag` (`tag`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userID`,`groupID`),
  ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `workflows`
--
ALTER TABLE `workflows`
  ADD PRIMARY KEY (`workflowID`);

--
-- Indexes for table `workflow_routes`
--
ALTER TABLE `workflow_routes`
  ADD UNIQUE KEY `workflowID` (`workflowID`,`stepID`,`actionType`),
  ADD KEY `stepID` (`stepID`),
  ADD KEY `actionType` (`actionType`);

--
-- Indexes for table `workflow_steps`
--
ALTER TABLE `workflow_steps`
  ADD PRIMARY KEY (`stepID`),
  ADD KEY `workflowID` (`workflowID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `action_history`
--
ALTER TABLE `action_history`
  MODIFY `actionID` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `action_types`
--
ALTER TABLE `action_types`
  MODIFY `actionTypeID` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `approvals`
--
ALTER TABLE `approvals`
  MODIFY `approvalID` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dependencies`
--
ALTER TABLE `dependencies`
  MODIFY `dependencyID` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `groupID` mediumint(9) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `indicators`
--
ALTER TABLE `indicators`
  MODIFY `indicatorID` smallint(5) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `noteID` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `records`
--
ALTER TABLE `records`
  MODIFY `recordID` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `serviceID` smallint(5) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `short_links`
--
ALTER TABLE `short_links`
  MODIFY `shortID` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `signatures`
--
ALTER TABLE `signatures`
  MODIFY `signatureID` mediumint(9) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `workflows`
--
ALTER TABLE `workflows`
  MODIFY `workflowID` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `workflow_steps`
--
ALTER TABLE `workflow_steps`
  MODIFY `stepID` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `action_history`
--
ALTER TABLE `action_history`
  ADD CONSTRAINT `action_history_ibfk_2` FOREIGN KEY (`actionTypeID`) REFERENCES `action_types` (`actionTypeID`);

--
-- Constraints for table `category_count`
--
ALTER TABLE `category_count`
  ADD CONSTRAINT `category_count_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`);

--
-- Constraints for table `category_privs`
--
ALTER TABLE `category_privs`
  ADD CONSTRAINT `category_privs_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`);

--
-- Constraints for table `category_staples`
--
ALTER TABLE `category_staples`
  ADD CONSTRAINT `category_staples_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dependency_privs`
--
ALTER TABLE `dependency_privs`
  ADD CONSTRAINT `fk_privs_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies` (`dependencyID`);

--
-- Constraints for table `indicators`
--
ALTER TABLE `indicators`
  ADD CONSTRAINT `indicators_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`);

--
-- Constraints for table `records_dependencies`
--
ALTER TABLE `records_dependencies`
  ADD CONSTRAINT `fk_records_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies` (`dependencyID`);

--
-- Constraints for table `route_events`
--
ALTER TABLE `route_events`
  ADD CONSTRAINT `route_events_ibfk_1` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`),
  ADD CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`);

--
-- Constraints for table `step_dependencies`
--
ALTER TABLE `step_dependencies`
  ADD CONSTRAINT `fk_step_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies` (`dependencyID`),
  ADD CONSTRAINT `step_dependencies_ibfk_3` FOREIGN KEY (`stepID`) REFERENCES `workflow_steps` (`stepID`);

--
-- Constraints for table `workflow_routes`
--
ALTER TABLE `workflow_routes`
  ADD CONSTRAINT `workflow_routes_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows` (`workflowID`),
  ADD CONSTRAINT `workflow_routes_ibfk_3` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`);

--
-- Constraints for table `workflow_steps`
--
ALTER TABLE `workflow_steps`
  ADD CONSTRAINT `workflow_steps_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows` (`workflowID`);
COMMIT;
