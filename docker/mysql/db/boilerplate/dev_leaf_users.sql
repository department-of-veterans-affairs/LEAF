INSERT INTO `employee` (`userName`, `lastName`, `firstName`, `middleName`, `phoneticFirstName`, `phoneticLastName`, `domain`, `deleted`, `lastUpdated`, `new_empUUID`)
VALUES ('tester', 'Tester', 'Tester', '', '', '', NULL, '0', '0', NULL);

INSERT INTO `relation_group_employee` (`groupID`, `empUID`)
VALUES ('1', '1');
