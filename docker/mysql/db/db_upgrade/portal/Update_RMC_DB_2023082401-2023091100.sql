START TRANSACTION;

CREATE TABLE `destruction_log` (
    recordID MEDIUMINT(8) UNSIGNED NOT NULL,
    categoryID VARCHAR(20) NOT NULL,
    destructionTime INT(10) UNSIGNED DEFAULT 0 NULL,
    PRIMARY KEY (recordID)
);
CREATE INDEX destructionTime
    ON `destruction_log` (`destructionTime`);
CREATE INDEX destructionForm
    ON `destruction_log` (`categoryID`);

ALTER TABLE `categories` MODIFY `destructionAge` mediumint(8) UNSIGNED NULL DEFAULT NULL;
CREATE INDEX destructionAge
    ON `categories` (`destructionAge`);

ALTER TABLE records_dependencies ADD CONSTRAINT fk_records_dependencies_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE records_step_fulfillment ADD CONSTRAINT fk_records_step_fulfillment_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE records_workflow_state ADD CONSTRAINT fk_records_workflow_state_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE notes ADD CONSTRAINT fk_records_notes_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE email_tracker ADD CONSTRAINT fk_records_email_tracker_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE data_history ADD CONSTRAINT fk_records_data_history_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE `data` ADD CONSTRAINT fk_records_data_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE category_count ADD CONSTRAINT fk_records_category_count_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE action_history ADD CONSTRAINT fk_records_action_history_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE signatures ADD CONSTRAINT fk_records_signatures_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;
ALTER TABLE tags ADD CONSTRAINT fk_records_tags_deletion
    FOREIGN KEY (recordID) REFERENCES records (recordID) ON DELETE CASCADE;


ALTER TABLE `data` ADD FULLTEXT `data` (`data`);

UPDATE `settings` SET `data` = '2023091100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

DROP TABLE `destruction_log`;

ALTER TABLE `categories` MODIFY `destructionAge` smallint(5) UNSIGNED NULL DEFAULT NULL;
DROP INDEX destructionAge ON `categories`;

ALTER TABLE records_dependencies DROP FOREIGN KEY fk_records_dependencies_deletion;
ALTER TABLE records_step_fulfillment DROP FOREIGN KEY fk_records_step_fulfillment_deletion;
ALTER TABLE records_workflow_state DROP FOREIGN KEY fk_records_workflow_state_deletion;
ALTER TABLE notes DROP FOREIGN KEY fk_records_notes_deletion;
ALTER TABLE email_tracker DROP FOREIGN KEY fk_records_email_tracker_deletion;
ALTER TABLE data_history DROP FOREIGN KEY fk_records_data_history_deletion;
ALTER TABLE `data` DROP FOREIGN KEY fk_records_data_deletion;
ALTER TABLE category_count DROP FOREIGN KEY fk_records_category_count_deletion;
ALTER TABLE action_history DROP FOREIGN KEY fk_records_action_history_deletion;
ALTER TABLE signatures DROP FOREIGN KEY fk_records_signatures_deletion;
ALTER TABLE tags DROP FOREIGN KEY fk_records_tags_deletion;


ALTER TABLE `data` DROP INDEX `data`;

UPDATE `settings` SET `data` = '2023082401' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/
