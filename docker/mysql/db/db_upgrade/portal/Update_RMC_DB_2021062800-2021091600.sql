START TRANSACTION;

DROP PROCEDURE IF EXISTS PROC_DROP_FOREIGN_KEY;
    DELIMITER $$
    CREATE PROCEDURE PROC_DROP_FOREIGN_KEY(IN tableName VARCHAR(64), IN constraintName VARCHAR(64))
    BEGIN
        IF EXISTS(
            SELECT * FROM information_schema.table_constraints
            WHERE 
                table_schema    = DATABASE()     AND
                table_name      = tableName      AND
                constraint_name = constraintName AND
                constraint_type = 'FOREIGN KEY')
        THEN
            SET @query = CONCAT('ALTER TABLE ', tableName, ' DROP FOREIGN KEY ', constraintName, ';');
            PREPARE stmt FROM @query; 
            EXECUTE stmt; 
            DEALLOCATE PREPARE stmt; 
        END IF; 
    END$$
    DELIMITER ;

ALTER TABLE `events` ADD COLUMN `eventType` varchar(40) NOT NULL AFTER `eventDescription`;
CALL PROC_DROP_FOREIGN_KEY('route_events', 'route_events_ibfk_2');
ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

UPDATE `events` SET `eventType` = 'Email' WHERE `eventID` = 'std_email_notify_completed' OR `eventID` = 'std_email_notify_next_approver';
UPDATE `events` SET `eventDescription` = 'Notify the requestor' WHERE `eventID` = 'std_email_notify_completed';
UPDATE `events` SET `eventDescription` = 'Notify the next approver' WHERE `eventID` = 'std_email_notify_next_approver';

UPDATE `settings` SET `data` = '2021091600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB ****

START TRANSACTION;

DELETE FROM `events` WHERE eventID LIKE "CustomEvent_%";
DELETE FROM `email_templates` WHERE emailTemplateID > 1;

ALTER TABLE `events` DROP COLUMN `eventType`;
ALTER TABLE `route_events` DROP FOREIGN KEY `route_events_ibfk_2`;
ALTER TABLE `route_events` ADD CONSTRAINT `route_events_ibfk_2` FOREIGN KEY (`eventID`) REFERENCES `events` (`eventID`);

UPDATE `events` SET eventDescription='Notify the requestor via email' WHERE eventID='std_email_notify_completed';
UPDATE `events` SET eventDescription='Notify the next approver via email' WHERE eventID='std_email_notify_next_approver';

UPDATE `settings` SET `data` = '2021062800' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

*/
