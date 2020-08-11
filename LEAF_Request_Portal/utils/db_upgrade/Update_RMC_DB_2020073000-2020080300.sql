START TRANSACTION;

CREATE TABLE `email_reminders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflowID` smallint(6) NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `frequency` smallint(5) NOT NULL,
  `recipientGroupID` mediumint(9) NOT NULL,
  `emailTemplate` text NOT NULL,
  `startDateIndicatorID` smallint(5) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `routeID` (`workflowID`,`stepID`,`actionType`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;


UPDATE `settings` SET `data` = '2020080300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
