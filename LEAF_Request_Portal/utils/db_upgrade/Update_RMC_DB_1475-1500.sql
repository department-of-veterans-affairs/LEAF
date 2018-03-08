START TRANSACTION;
ALTER TABLE `action_history`  ADD `dependencyID` TINYINT UNSIGNED NOT NULL AFTER `userID`;
UPDATE `settings` SET `data` = '1500' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
