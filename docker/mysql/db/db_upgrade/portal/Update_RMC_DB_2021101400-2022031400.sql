START TRANSACTION;

CREATE TABLE `indicator_conditions`
(
    `indicatorID` smallint(5) NOT NULL,
    `condition` text NULL,
    CONSTRAINT `indicator_conditions_pk`
        PRIMARY KEY (`indicatorID`)
);

UPDATE `settings` SET `data` = '2022031400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

DROP TABLE `indicator_conditions`;

UPDATE `settings` SET `data` = '2021101400' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
