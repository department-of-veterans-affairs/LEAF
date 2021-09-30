START TRANSACTION;
DROP TABLE `dependency_actions`;

UPDATE `settings` SET `data` = '1464' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
