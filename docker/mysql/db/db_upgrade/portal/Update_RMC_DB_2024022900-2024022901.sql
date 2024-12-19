START TRANSACTION;

ALTER TABLE `sites` ADD COLUMN `launchpadID` mediumint(8) unsigned NOT NULL AFTER `id`;
ALTER TABLE `sites` ADD COLUMN `decommissionTimestamp` int(11) DEFAULT '0' AFTER `orgchart_database`;
ALTER TABLE `sites` ADD INDEX `launchpadID` (`launchpadID`);

 UPDATE `settings` SET `data` = '2024022901' WHERE `settings`.`setting` = 'dbversion';

 COMMIT;


 /**** Revert DB *****
 START TRANSACTION;
 ALTER TABLE `sites` DROP INDEX `launchpadID`;
 ALTER TABLE `sites` DROP COLUMN `launchpadID`;
 ALTER TABLE `sites` DROP COLUMN `decommissionTimestamp`;

 UPDATE `settings` SET `data` = '2024022900' WHERE `settings`.`setting` = 'dbversion';
 COMMIT;
 */
