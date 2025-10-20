START TRANSACTION;

UPDATE `categories` SET `needToKnow` = 1;

UPDATE `settings` SET `data` = '2025103100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;

/**** Revert DB *****
START TRANSACTION;


This cannot be reverted automatically.

COMMIT;
*/
