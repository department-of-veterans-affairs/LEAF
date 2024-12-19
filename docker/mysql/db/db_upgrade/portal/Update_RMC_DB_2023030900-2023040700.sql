START TRANSACTION;

 CREATE TABLE `template_history_files` (
   `file_id` int(11) NOT NULL AUTO_INCREMENT,
   `file_parent_name` text,
   `file_name` text,
   `file_path` text,
   `file_size` mediumint(9) DEFAULT NULL,
   `file_modify_by` text,
   `file_created` text,
   PRIMARY KEY (`file_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 UPDATE `settings` SET `data` = '2023040700' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DROP TABLE IF EXISTS `template_history_files`;
 UPDATE `settings` SET `data` = '2023030900' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */