START TRANSACTION;

CREATE TABLE IF NOT EXISTS `category_staples` (
  `categoryID` varchar(20) NOT NULL,
  `stapledCategoryID` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `category_staples`
  ADD KEY `categoryID` (`categoryID`);

ALTER TABLE `category_staples` ADD FOREIGN KEY (`categoryID`) REFERENCES `categories`(`categoryID`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `category_staples` ADD UNIQUE `category_stapled` (`categoryID`, `stapledCategoryID`);

UPDATE `settings` SET `data` = '4936' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
