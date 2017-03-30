
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- --------------------------------------------------------

--
-- Table structure for table `actions`
--

CREATE TABLE IF NOT EXISTS `actions` (
  `actionType` varchar(50) NOT NULL,
  `actionText` varchar(50) NOT NULL,
  `actionTextPasttense` varchar(50) NOT NULL,
  `actionIcon` varchar(50) NOT NULL,
  `actionAlignment` varchar(20) NOT NULL,
  `sort` tinyint(4) NOT NULL,
  `fillDependency` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `actions`
--

INSERT INTO `actions` (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`) VALUES
('approve', 'Approve', 'Approved', 'gnome-emblem-default.svg', 'right', 0, 1),
('concur', 'Concur', 'Concurred', 'go-next.svg', 'right', 1, 1),
('defer', 'Defer', 'Deferred', 'software-update-urgent.svg', 'left', 0, -2),
('disapprove', 'Disapprove', 'Disapproved', 'process-stop.svg', 'left', 0, -1),
('sendback', 'Send Back', 'Sent Back', 'edit-undo.svg', 'left', 0, 0),
('submit', 'Submit', 'Submitted', 'gnome-emblem-default.svg', 'right', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `action_history`
--

CREATE TABLE IF NOT EXISTS `action_history` (
  `actionID` mediumint(8) unsigned NOT NULL,
  `recordID` smallint(5) unsigned NOT NULL,
  `userID` varchar(50) NOT NULL,
  `dependencyID` tinyint(3) unsigned NOT NULL,
  `groupID` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `actionType` varchar(50) NOT NULL,
  `actionTypeID` tinyint(3) unsigned NOT NULL,
  `time` int(10) unsigned NOT NULL,
  `comment` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `action_types`
--

CREATE TABLE IF NOT EXISTS `action_types` (
  `actionTypeID` tinyint(3) unsigned NOT NULL,
  `actionTypeDesc` varchar(50) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

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

CREATE TABLE IF NOT EXISTS `approvals` (
  `approvalID` mediumint(8) unsigned NOT NULL,
  `recordID` smallint(5) unsigned NOT NULL,
  `userID` varchar(50) NOT NULL,
  `groupID` mediumint(9) NOT NULL DEFAULT '0',
  `approvalType` varchar(50) NOT NULL,
  `time` int(10) unsigned NOT NULL,
  `comment` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE IF NOT EXISTS `categories` (
  `categoryID` varchar(20) NOT NULL,
  `parentID` varchar(50) NOT NULL,
  `categoryName` varchar(50) NOT NULL,
  `categoryDescription` varchar(255) NOT NULL,
  `workflowID` tinyint(3) unsigned NOT NULL,
  `sort` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `disabled` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `category_count`
--

CREATE TABLE IF NOT EXISTS `category_count` (
  `recordID` smallint(5) unsigned NOT NULL,
  `categoryID` varchar(20) NOT NULL,
  `count` tinyint(3) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `category_dependencies`
--

CREATE TABLE IF NOT EXISTS `category_dependencies` (
  `categoryID` varchar(20) NOT NULL,
  `dependencyID` smallint(6) NOT NULL,
  `state` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `category_privs`
--

CREATE TABLE IF NOT EXISTS `category_privs` (
  `categoryID` varchar(20) NOT NULL,
  `groupID` mediumint(9) NOT NULL,
  `readable` tinyint(4) NOT NULL,
  `writable` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `data`
--

CREATE TABLE IF NOT EXISTS `data` (
  `recordID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `series` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `data` text NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `data_cache`
--

CREATE TABLE IF NOT EXISTS `data_cache` (
  `cacheKey` varchar(32) NOT NULL,
  `data` text NOT NULL,
  `timestamp` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `data_history`
--

CREATE TABLE IF NOT EXISTS `data_history` (
  `recordID` smallint(5) unsigned NOT NULL,
  `indicatorID` smallint(5) NOT NULL,
  `series` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `data` text NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dependencies`
--

CREATE TABLE IF NOT EXISTS `dependencies` (
  `dependencyID` smallint(6) NOT NULL,
  `description` varchar(50) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dependency_privs`
--

CREATE TABLE IF NOT EXISTS `dependency_privs` (
  `dependencyID` smallint(6) NOT NULL,
  `groupID` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE IF NOT EXISTS `events` (
  `eventID` varchar(40) NOT NULL,
  `eventDescription` varchar(200) NOT NULL,
  `event` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`eventID`, `eventDescription`, `event`) VALUES
('std_email_notify_completed', 'Standard notification alerting requestor of approved request', ''),
('std_email_notify_next_approver', 'Standard Email Notification for next approver', '');

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE IF NOT EXISTS `groups` (
  `groupID` mediumint(9) NOT NULL,
  `parentGroupID` tinyint(4) DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `groupDescription` varchar(50) NOT NULL DEFAULT ''
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

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

CREATE TABLE IF NOT EXISTS `indicators` (
  `indicatorID` smallint(5) NOT NULL,
  `name` text NOT NULL,
  `format` text NOT NULL,
  `description` varchar(50) DEFAULT NULL,
  `default` varchar(20) DEFAULT NULL,
  `parentID` smallint(5) unsigned DEFAULT NULL,
  `categoryID` varchar(20) DEFAULT NULL,
  `html` varchar(510) DEFAULT NULL,
  `htmlPrint` text,
  `jsSort` varchar(255) DEFAULT NULL,
  `required` tinyint(4) NOT NULL DEFAULT '0',
  `sort` tinyint(4) NOT NULL DEFAULT '1',
  `timeAdded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `disabled` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `indicator_mask`
--

CREATE TABLE IF NOT EXISTS `indicator_mask` (
  `indicatorID` smallint(5) NOT NULL,
  `groupID` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE IF NOT EXISTS `notes` (
  `noteID` mediumint(8) unsigned NOT NULL,
  `recordID` smallint(5) unsigned NOT NULL,
  `note` text NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL,
  `deleted` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `pair_category_serviceiid`
--

CREATE TABLE IF NOT EXISTS `pair_category_serviceiid` (
  `categoryID` varchar(50) CHARACTER SET utf8 NOT NULL,
  `serviceIndicatorID` smallint(5) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `records`
--

CREATE TABLE IF NOT EXISTS `records` (
  `recordID` smallint(5) unsigned NOT NULL,
  `date` int(10) unsigned NOT NULL,
  `serviceID` smallint(5) unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL,
  `title` text,
  `priority` tinyint(4) NOT NULL DEFAULT '0',
  `lastStatus` varchar(200) DEFAULT NULL,
  `submitted` int(10) NOT NULL DEFAULT '0',
  `deleted` int(10) NOT NULL DEFAULT '0',
  `isWritableUser` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `isWritableGroup` tinyint(3) unsigned NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records_dependencies`
--

CREATE TABLE IF NOT EXISTS `records_dependencies` (
  `recordID` smallint(5) unsigned NOT NULL,
  `dependencyID` smallint(6) NOT NULL,
  `filled` tinyint(3) NOT NULL DEFAULT '0',
  `time` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `records_workflow_state`
--

CREATE TABLE IF NOT EXISTS `records_workflow_state` (
  `recordID` smallint(6) NOT NULL,
  `stepID` tinyint(4) unsigned NOT NULL,
  `blockingStepID` tinyint(4) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `route_events`
--

CREATE TABLE IF NOT EXISTS `route_events` (
  `workflowID` tinyint(3) unsigned NOT NULL,
  `stepID` tinyint(3) unsigned NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `eventID` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE IF NOT EXISTS `services` (
  `serviceID` smallint(5) unsigned NOT NULL,
  `service` varchar(100) NOT NULL,
  `abbreviatedService` varchar(25) NOT NULL,
  `groupID` mediumint(9) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `service_chiefs`
--

CREATE TABLE IF NOT EXISTS `service_chiefs` (
  `serviceID` smallint(5) unsigned NOT NULL,
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `service_data`
--

CREATE TABLE IF NOT EXISTS `service_data` (
  `serviceID` smallint(5) unsigned NOT NULL,
  `serviceIndicatorID` smallint(5) unsigned NOT NULL,
  `data` text NOT NULL,
  `timestamp` int(11) NOT NULL,
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `service_data_history`
--

CREATE TABLE IF NOT EXISTS `service_data_history` (
  `serviceID` smallint(5) unsigned NOT NULL,
  `serviceIndicatorID` smallint(5) unsigned NOT NULL,
  `data` text NOT NULL,
  `timestamp` int(11) NOT NULL,
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `service_indicatorid`
--

CREATE TABLE IF NOT EXISTS `service_indicatorid` (
  `serviceIndicatorID` smallint(5) unsigned NOT NULL,
  `name` text NOT NULL,
  `format` text NOT NULL,
  `description` varchar(50) NOT NULL,
  `default` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `setting` varchar(20) NOT NULL,
  `data` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`setting`, `data`) VALUES
('dbversion', '3848'),
('version', '2240');

-- --------------------------------------------------------

--
-- Table structure for table `step_dependencies`
--

CREATE TABLE IF NOT EXISTS `step_dependencies` (
  `stepID` smallint(6) NOT NULL,
  `dependencyID` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--

CREATE TABLE IF NOT EXISTS `tags` (
  `recordID` smallint(5) unsigned NOT NULL,
  `tag` varchar(50) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL DEFAULT '0',
  `userID` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `userID` varchar(50) NOT NULL,
  `groupID` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `workflows`
--

CREATE TABLE IF NOT EXISTS `workflows` (
  `workflowID` tinyint(4) unsigned NOT NULL,
  `initialStepID` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `description` varchar(64) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `workflow_routes`
--

CREATE TABLE IF NOT EXISTS `workflow_routes` (
  `workflowID` tinyint(3) unsigned NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `nextStepID` tinyint(3) unsigned NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `displayConditional` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `workflow_steps`
--

CREATE TABLE IF NOT EXISTS `workflow_steps` (
  `workflowID` tinyint(3) unsigned NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `stepTitle` varchar(64) NOT NULL,
  `stepBgColor` varchar(10) NOT NULL DEFAULT '#fffdcd',
  `stepFontColor` varchar(10) NOT NULL DEFAULT 'black',
  `stepBorder` varchar(20) NOT NULL DEFAULT '1px solid black',
  `jsSrc` varchar(128) NOT NULL,
  `posX` smallint(6) DEFAULT NULL,
  `posY` smallint(6) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

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
  ADD PRIMARY KEY (`actionID`), ADD KEY `time` (`time`), ADD KEY `recordID` (`recordID`), ADD KEY `actionTypeID` (`actionTypeID`), ADD KEY `groupID` (`groupID`), ADD KEY `dependencyID` (`dependencyID`), ADD KEY `actionType` (`actionType`);

--
-- Indexes for table `action_types`
--
ALTER TABLE `action_types`
  ADD PRIMARY KEY (`actionTypeID`);

--
-- Indexes for table `approvals`
--
ALTER TABLE `approvals`
  ADD PRIMARY KEY (`approvalID`), ADD KEY `time` (`time`), ADD KEY `recordID` (`recordID`), ADD KEY `groupID` (`groupID`), ADD KEY `record_group` (`recordID`,`groupID`), ADD KEY `record_time` (`recordID`,`time`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`categoryID`), ADD KEY `parentID` (`parentID`);

--
-- Indexes for table `category_count`
--
ALTER TABLE `category_count`
  ADD PRIMARY KEY (`recordID`,`categoryID`), ADD KEY `categoryID` (`categoryID`);

--
-- Indexes for table `category_dependencies`
--
ALTER TABLE `category_dependencies`
  ADD UNIQUE KEY `categoryID_2` (`categoryID`,`dependencyID`), ADD KEY `sort` (`state`), ADD KEY `categoryID` (`categoryID`), ADD KEY `dependencyID` (`dependencyID`);

--
-- Indexes for table `category_privs`
--
ALTER TABLE `category_privs`
  ADD UNIQUE KEY `categoryID` (`categoryID`,`groupID`), ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `data`
--
ALTER TABLE `data`
  ADD UNIQUE KEY `unique` (`recordID`,`indicatorID`,`series`), ADD KEY `indicator_series` (`indicatorID`,`series`);

--
-- Indexes for table `data_cache`
--
ALTER TABLE `data_cache`
  ADD UNIQUE KEY `cacheKey` (`cacheKey`);

--
-- Indexes for table `data_history`
--
ALTER TABLE `data_history`
  ADD KEY `recordID` (`recordID`,`indicatorID`,`series`), ADD KEY `timestamp` (`timestamp`);

--
-- Indexes for table `dependencies`
--
ALTER TABLE `dependencies`
  ADD PRIMARY KEY (`dependencyID`);

--
-- Indexes for table `dependency_privs`
--
ALTER TABLE `dependency_privs`
  ADD UNIQUE KEY `dependencyID` (`dependencyID`,`groupID`), ADD KEY `groupID` (`groupID`);

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
  ADD PRIMARY KEY (`indicatorID`), ADD KEY `parentID` (`parentID`), ADD KEY `categoryID` (`categoryID`), ADD KEY `sort` (`sort`);

--
-- Indexes for table `indicator_mask`
--
ALTER TABLE `indicator_mask`
  ADD UNIQUE KEY `indicatorID_2` (`indicatorID`,`groupID`), ADD KEY `indicatorID` (`indicatorID`), ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`noteID`), ADD KEY `recordID` (`recordID`);

--
-- Indexes for table `pair_category_serviceiid`
--
ALTER TABLE `pair_category_serviceiid`
  ADD KEY `categoryID` (`categoryID`), ADD KEY `serviceIndicatorID` (`serviceIndicatorID`);

--
-- Indexes for table `records`
--
ALTER TABLE `records`
  ADD PRIMARY KEY (`recordID`), ADD KEY `date` (`date`), ADD KEY `deleted` (`deleted`), ADD KEY `serviceID` (`serviceID`);

--
-- Indexes for table `records_dependencies`
--
ALTER TABLE `records_dependencies`
  ADD UNIQUE KEY `recordID` (`recordID`,`dependencyID`), ADD KEY `filled` (`dependencyID`,`filled`), ADD KEY `time` (`time`);

--
-- Indexes for table `records_workflow_state`
--
ALTER TABLE `records_workflow_state`
  ADD UNIQUE KEY `recordID` (`recordID`,`stepID`);

--
-- Indexes for table `route_events`
--
ALTER TABLE `route_events`
  ADD UNIQUE KEY `workflowID_2` (`workflowID`,`stepID`,`actionType`,`eventID`), ADD KEY `eventID` (`eventID`), ADD KEY `workflowID` (`workflowID`,`stepID`,`actionType`), ADD KEY `actionType` (`actionType`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`serviceID`), ADD UNIQUE KEY `service` (`service`), ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `service_chiefs`
--
ALTER TABLE `service_chiefs`
  ADD UNIQUE KEY `serviceID_2` (`serviceID`,`userID`), ADD KEY `serviceID` (`serviceID`), ADD KEY `userID` (`userID`);

--
-- Indexes for table `service_data`
--
ALTER TABLE `service_data`
  ADD KEY `serviceID` (`serviceID`), ADD KEY `serviceIndicatorID` (`serviceIndicatorID`);

--
-- Indexes for table `service_data_history`
--
ALTER TABLE `service_data_history`
  ADD KEY `serviceID` (`serviceID`), ADD KEY `serviceIndicatorID` (`serviceIndicatorID`);

--
-- Indexes for table `service_indicatorid`
--
ALTER TABLE `service_indicatorid`
  ADD PRIMARY KEY (`serviceIndicatorID`);

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
-- Indexes for table `step_dependencies`
--
ALTER TABLE `step_dependencies`
  ADD UNIQUE KEY `stepID` (`stepID`,`dependencyID`), ADD KEY `dependencyID` (`dependencyID`);

--
-- Indexes for table `tags`
--
ALTER TABLE `tags`
  ADD UNIQUE KEY `recordID` (`recordID`,`tag`), ADD KEY `tag` (`tag`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userID`,`groupID`), ADD KEY `groupID` (`groupID`);

--
-- Indexes for table `workflows`
--
ALTER TABLE `workflows`
  ADD PRIMARY KEY (`workflowID`);

--
-- Indexes for table `workflow_routes`
--
ALTER TABLE `workflow_routes`
  ADD UNIQUE KEY `workflowID` (`workflowID`,`stepID`,`actionType`), ADD KEY `stepID` (`stepID`), ADD KEY `actionType` (`actionType`);

--
-- Indexes for table `workflow_steps`
--
ALTER TABLE `workflow_steps`
  ADD PRIMARY KEY (`stepID`), ADD KEY `workflowID` (`workflowID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `action_history`
--
ALTER TABLE `action_history`
  MODIFY `actionID` mediumint(8) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `action_types`
--
ALTER TABLE `action_types`
  MODIFY `actionTypeID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `approvals`
--
ALTER TABLE `approvals`
  MODIFY `approvalID` mediumint(8) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `dependencies`
--
ALTER TABLE `dependencies`
  MODIFY `dependencyID` smallint(6) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `groupID` mediumint(9) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `indicators`
--
ALTER TABLE `indicators`
  MODIFY `indicatorID` smallint(5) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `noteID` mediumint(8) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `records`
--
ALTER TABLE `records`
  MODIFY `recordID` smallint(5) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `serviceID` smallint(5) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `service_indicatorid`
--
ALTER TABLE `service_indicatorid`
  MODIFY `serviceIndicatorID` smallint(5) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `workflows`
--
ALTER TABLE `workflows`
  MODIFY `workflowID` tinyint(4) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `workflow_steps`
--
ALTER TABLE `workflow_steps`
  MODIFY `stepID` smallint(6) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=14;
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
-- Constraints for table `category_dependencies`
--
ALTER TABLE `category_dependencies`
ADD CONSTRAINT `fk_category_dependencyID` FOREIGN KEY (`dependencyID`) REFERENCES `dependencies` (`dependencyID`),
ADD CONSTRAINT `category_dependencies_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`);

--
-- Constraints for table `category_privs`
--
ALTER TABLE `category_privs`
ADD CONSTRAINT `category_privs_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`);

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
-- Constraints for table `pair_category_serviceiid`
--
ALTER TABLE `pair_category_serviceiid`
ADD CONSTRAINT `pair_category_serviceiid_ibfk_1` FOREIGN KEY (`serviceIndicatorID`) REFERENCES `service_indicatorid` (`serviceIndicatorID`),
ADD CONSTRAINT `pair_category_serviceiid_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `categories` (`categoryID`);

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
ADD CONSTRAINT `workflow_routes_ibfk_4` FOREIGN KEY (`stepID`) REFERENCES `workflow_steps` (`stepID`),
ADD CONSTRAINT `workflow_routes_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows` (`workflowID`),
ADD CONSTRAINT `workflow_routes_ibfk_3` FOREIGN KEY (`actionType`) REFERENCES `actions` (`actionType`);

--
-- Constraints for table `workflow_steps`
--
ALTER TABLE `workflow_steps`
ADD CONSTRAINT `workflow_steps_ibfk_1` FOREIGN KEY (`workflowID`) REFERENCES `workflows` (`workflowID`);

INSERT INTO `dependencies` (`dependencyID`, `description`) VALUES ('1', 'Service Chief'), ('8', 'Quadrad');
