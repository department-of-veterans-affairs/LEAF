START TRANSACTION;

UPDATE `actions` SET `actionText` = 'Return to Requestor' WHERE `actions`.`actionType` = 'sendback';
UPDATE `actions` SET `actionTextPasttense` = 'Returned to Requestor' WHERE `actions`.`actionType` = 'sendback';

UPDATE `settings` SET `data` = '4290' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
