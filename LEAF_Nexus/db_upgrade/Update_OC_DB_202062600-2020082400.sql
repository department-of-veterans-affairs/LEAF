START TRANSACTION;

CREATE TABLE `test` (
  `id` INT NOT NULL,
  PRIMARY KEY (`id`));
DROP TABLE `test`;

UPDATE `settings` SET `data` = '2020082400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
