START TRANSACTION;

CREATE TABLE `sites` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `site_type` varchar(8) NOT NULL,
  `site_path` varchar(250) NOT NULL,
  `site_uploads` varchar(250) DEFAULT NULL,
  `portal_database` varchar(250) DEFAULT NULL,
  `orgchart_path` varchar(250) DEFAULT NULL,
  `orgchart_database` varchar(250) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `site_path` (`site_path`),
  KEY `site_type` (`site_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

 UPDATE `settings` SET `data` = '2024022900' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 DROP TABLE IF EXISTS `sites`;
 UPDATE `settings` SET `data` = '2023100500' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */
