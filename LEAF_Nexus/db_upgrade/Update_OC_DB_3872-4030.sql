START TRANSACTION;

CREATE TABLE IF NOT EXISTS `tag_hierarchy` (
  `tag` varchar(50) NOT NULL,
  `parentTag` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `tag_hierarchy`
  ADD PRIMARY KEY (`tag`), ADD KEY `parentTag` (`parentTag`);

INSERT INTO `tag_hierarchy` (`tag`, `parentTag`) VALUES
('quadrad', NULL),
('service', 'quadrad');

UPDATE `settings` SET `data` = '4030' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
