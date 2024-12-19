START TRANSACTION;

CREATE TABLE `short_links` (
  `shortID` mediumint(8) UNSIGNED NOT NULL,
  `type` varchar(20) NOT NULL,
  `hash` varchar(64) NOT NULL,
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `short_links`
  ADD PRIMARY KEY (`shortID`),
  ADD UNIQUE KEY `type_hash` (`type`,`hash`);

ALTER TABLE `short_links`
  MODIFY `shortID` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT;

UPDATE `settings` SET `data` = '5366' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
