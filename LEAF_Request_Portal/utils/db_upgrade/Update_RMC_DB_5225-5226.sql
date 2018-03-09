START TRANSACTION;

-- New action to indicate a digital signature 
INSERT INTO `actions` 
    (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`)
    VALUES ('sign', 'Sign', 'Signed', 'application-certificate.svg', 'right', 0, 0);

-- Add signature field to action_history, create index
ALTER TABLE `action_history` ADD `signature` VARCHAR(255) DEFAULT NULL;
ALTER TABLE `action_history` ADD INDEX `signatureIDX` (`signature`);

-- Add digital signature requirement column to workflow_steps
ALTER TABLE `workflow_steps` ADD `requiresDigitalSignature` TINYINT(1) DEFAULT NULL;
COMMIT;

START TRANSACTION;
-- Create table to hold signatures
CREATE TABLE IF NOT EXISTS `signatures` (
    `signature` VARCHAR(255) NOT NULL,
    `recordID`  SMALLINT(5) unsigned NOT NULL,
    `actionID`  MEDIUMINT(8) unsigned NOT NULL,

    -- Typically this will hold a JSON object, but the MySQL JSON data type is not used here since the JSON document
    -- elements will never be accessed individually and this is here only for accounting and validation purposes
    `message`   LONGTEXT NOT NULL,

    PRIMARY KEY (`signature`),
    CONSTRAINT `action_history_signature_fk` 
        FOREIGN KEY (`signature`) 
        REFERENCES `action_history` (`signature`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE `settings` SET `data` = '5226' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
