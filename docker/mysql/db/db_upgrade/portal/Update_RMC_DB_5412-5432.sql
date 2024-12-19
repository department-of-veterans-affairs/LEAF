START TRANSACTION;

ALTER TABLE `signatures` ADD `signerPublicKey` TEXT NOT NULL AFTER `message`;

UPDATE `settings` SET `data` = '5432' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
