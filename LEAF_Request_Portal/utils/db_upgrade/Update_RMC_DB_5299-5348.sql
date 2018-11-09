START TRANSACTION;

-- New action to indicate a digital signature 
INSERT IGNORE INTO `actions` 
    (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`)
    VALUES ('sign', 'Sign', 'Signed', 'application-certificate.svg', 'right', 0, 1);

-- Add digital signature requirement column to workflow_steps
ALTER TABLE `workflow_steps` ADD `requiresDigitalSignature` TINYINT(1) DEFAULT NULL;

-- Create table to hold signatures
CREATE TABLE IF NOT EXISTS `signatures` (
    `signatureID`        MEDIUMINT(9) NOT NULL AUTO_INCREMENT,
    `signature` TEXT NOT NULL,
    `recordID`  SMALLINT(5) unsigned NOT NULL,
    `stepID`  SMALLINT(5) NOT NULL,
    `dependencyID`  SMALLINT(5) NOT NULL,

    -- Typically this will hold a JSON object, but the MySQL JSON data type is not used here since the JSON document
    -- elements will never be accessed individually and this is here only for accounting and validation purposes
    `message`   LONGTEXT NOT NULL,

    `userID`    VARCHAR(50) NOT NULL,
    `timestamp` INT unsigned NOT NULL,

    PRIMARY KEY (`signatureID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
ALTER TABLE `signatures` ADD UNIQUE `recordID_stepID_depID` (`recordID`, `stepID`, `dependencyID`);


UPDATE `settings` SET `data` = '5348' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
