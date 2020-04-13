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
(-3,	'Notify Requestor of Completion',	'LEAF_notify_complete_subject.tpl',	'LEAF_notify_complete_body.tpl'),
(-2,	'Notify Next Approver',	'LEAF_notify_next_subject.tpl',	'LEAF_notify_next_body.tpl'),
(-1,	'Send Back',	'LEAF_send_back_subject.tpl',	'LEAF_send_back_body.tpl');

UPDATE `settings` SET `data` = '2020041300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;