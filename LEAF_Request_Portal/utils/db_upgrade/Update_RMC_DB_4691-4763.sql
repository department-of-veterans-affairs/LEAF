START TRANSACTION;

ALTER TABLE `events`
CHANGE `event` `eventData` text COLLATE 'latin1_swedish_ci' NOT NULL AFTER `eventDescription`;
ALTER TABLE `categories`
CHANGE `sort` `sort` tinyint(3) NOT NULL DEFAULT '0' AFTER `workflowID`;

UPDATE `settings` SET `data` = '4763' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
