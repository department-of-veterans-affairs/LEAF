START TRANSACTION;

-- New action to indicate a digital signature 
INSERT INTO `actions` 
    (`actionType`, `actionText`, `actionTextPasttense`, `actionIcon`, `actionAlignment`, `sort`, `fillDependency`)
    VALUES ('sign', 'Sign', 'Signed', 'application-certificate.svg', 'right', 0, 1);

-- Add signature field to action_history
ALTER TABLE `action_history` ADD `signature_id` MEDIUMINT(9) DEFAULT NULL;

-- Add digital signature requirement column to workflow_steps
ALTER TABLE `workflow_steps` ADD `requiresDigitalSignature` TINYINT(1) DEFAULT NULL;
COMMIT;

START TRANSACTION;

-- Create table to hold signatures
CREATE TABLE IF NOT EXISTS `signatures` (
    `id`        MEDIUMINT(9) NOT NULL AUTO_INCREMENT,
    `signature` TEXT NOT NULL,
    `recordID`  SMALLINT(5) unsigned NOT NULL,

    -- Typically this will hold a JSON object, but the MySQL JSON data type is not used here since the JSON document
    -- elements will never be accessed individually and this is here only for accounting and validation purposes
    `message`   LONGTEXT NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Create foreign key on action_history for signatures id
ALTER TABLE `action_history` ADD 
    CONSTRAINT `signatures_id_fk`
    FOREIGN KEY (`signature_id`)
    REFERENCES `signatures` (`id`);

UPDATE `settings` SET `data` = '5226' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
