START TRANSACTION;

ALTER TABLE `action_history` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `approvals` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `data` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `data_extended` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `data_history` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `notes` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `records` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `service_chiefs` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `signatures` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `tags` CHANGE `userID` `empUID` varchar(36) NOT NULL;
ALTER TABLE `users` ADD `empUID` varchar(36) NOT NULL;

UPDATE `settings` SET `data` = '5373' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
