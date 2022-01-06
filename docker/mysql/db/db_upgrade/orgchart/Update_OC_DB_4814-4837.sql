START TRANSACTION;

ALTER TABLE `employee`
ADD `domain` varchar(16) COLLATE 'utf8_general_ci' NULL AFTER `phoneticLastName`;

ALTER TABLE `employee`
ADD INDEX `domain` (`domain`);

UPDATE `settings` SET `data` = '4837' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
