START TRANSACTION;

CREATE TABLE `email_templates` (
  `emailTemplateID` mediumint(8) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) NOT NULL,
  `subject` text NOT NULL,
  `body` text NOT NULL,
  PRIMARY KEY (`emailTemplateID`),
  UNIQUE KEY `label` (`label`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

INSERT INTO `email_templates` (`emailTemplateID`, `label`, `subject`, `body`) VALUES
(-3,	'Notify Requestor of Completion',	'notify_complete_subject.tpl',	'notify_complete_body.tpl'),
(-2,	'Notify Next Approver',	'notify_next_subject.tpl',	'notify_next_body.tpl'),
(-1,	'Send Back',	'send_back_subject.tpl',	'send_back_body.tpl');

UPDATE `settings` SET `data` = '2020031600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;