START TRANSACTION;

CREATE INDEX `userID` on `records` (`userID`);
CREATE INDEX `submitted` on `records` (`submitted`);
CREATE INDEX `fastdata` on `data` (`indicatorID`, `data`(10));

UPDATE `settings` SET `data` = '2021101400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

DROP INDEX `userID` on `records`;
DROP INDEX `submitted` on `records`;
DROP INDEX `fastdata` on `data`;

UPDATE `settings` SET `data` = '2021091600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
