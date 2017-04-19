START TRANSACTION;

CREATE TABLE `cache` (
  `cacheID` varchar(40) NOT NULL,
  `data` mediumtext NOT NULL,
  `cacheTime` int unsigned NOT NULL
);

ALTER TABLE `cache` ADD PRIMARY KEY `cacheID` (`cacheID`);

UPDATE `settings` SET `data` = '4688' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
