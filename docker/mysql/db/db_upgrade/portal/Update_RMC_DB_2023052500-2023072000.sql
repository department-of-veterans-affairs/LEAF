START TRANSACTION;

ALTER TABLE `records`
    ADD COLUMN `destructionGraceTime` int(10) DEFAULT 0 NOT NULL
    AFTER `deleted`;
CREATE INDEX destructionGraceTime
    ON `records` (`destructionGraceTime`);

UPDATE `settings` SET `data` = '2023072000' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;
DROP INDEX destructionGraceTime ON `records`;
ALTER TABLE `records` DROP COLUMN `destructionGraceTime`;
UPDATE `settings` SET `data` = '2023052500' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
*/