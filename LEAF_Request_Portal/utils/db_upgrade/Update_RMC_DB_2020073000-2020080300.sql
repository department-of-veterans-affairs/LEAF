START TRANSACTION;

INSERT INTO `events` (`eventID`, `eventDescription`, `eventData`) VALUES ('automated_email_reminder', 'Set Automated email reminders', '');

CREATE TABLE `email_reminders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflowID` smallint(6) NOT NULL,
  `stepID` smallint(6) NOT NULL,
  `actionType` varchar(50) NOT NULL,
  `frequency` smallint(5) NOT NULL,
  `recipientGroupID` mediumint(9) NOT NULL,
  `emailTemplateID` mediumint(8) NOT NULL,
  `startDateIndicatorID` smallint(5) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `routeID` (`workflowID`,`stepID`,`actionType`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
SELECT * FROM leaf_portal.email_reminders;

UPDATE `settings` SET `data` = '2020080300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
