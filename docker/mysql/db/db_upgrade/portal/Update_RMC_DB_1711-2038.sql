-- Comment out the ALTER TABLE query if the foreign key for action_history.groupID does not exist

START TRANSACTION;
ALTER TABLE `action_history` DROP FOREIGN KEY `action_history_ibfk_3`;

UPDATE `settings` SET `data` = '2038' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
