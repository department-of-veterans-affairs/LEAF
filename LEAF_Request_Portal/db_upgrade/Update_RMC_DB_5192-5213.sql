START TRANSACTION;

DROP TABLE `category_dependencies`;

UPDATE `settings` SET `data` = '5213' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
