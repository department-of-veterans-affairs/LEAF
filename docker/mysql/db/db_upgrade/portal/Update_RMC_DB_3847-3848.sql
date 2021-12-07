START TRANSACTION;

ALTER TABLE `action_history` DROP FOREIGN KEY `action_history_ibfk_1`;
ALTER TABLE `approvals` DROP FOREIGN KEY `approvals_ibfk_2`;
ALTER TABLE `category_count` DROP FOREIGN KEY `category_count_ibfk_2`;
ALTER TABLE `data_history` DROP FOREIGN KEY `data_history_ibfk_1`;
ALTER TABLE `data` DROP FOREIGN KEY `data_ibfk_1`;
ALTER TABLE `tags` DROP FOREIGN KEY `tags_ibfk_1`;
ALTER TABLE `records_dependencies` DROP FOREIGN KEY `records_dependencies_ibfk_3`;

UPDATE `settings` SET `data` = '3848' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
