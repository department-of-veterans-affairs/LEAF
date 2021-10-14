START TRANSACTION;

CREATE INDEX `userID` on `records` (`userID`);
CREATE INDEX `submitted` on `records` (`submitted`);

UPDATE `settings` SET `data` = '2021101400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;



UPDATE `settings` SET `data` = '2021091600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
