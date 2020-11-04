START TRANSACTION;
ALTER TABLE `actions` ADD `actionTextPasttense` VARCHAR( 20 ) NOT NULL AFTER `actionText`;
UPDATE `actions` SET `actionTextPasttense` = 'Approved' WHERE `actions`.`actionType` = 'approve';
UPDATE `actions` SET `actionTextPasttense` = 'Concurred' WHERE `actions`.`actionType` = 'concur';
UPDATE `actions` SET `actionTextPasttense` = 'Deferred' WHERE `actions`.`actionType` = 'defer';
UPDATE `actions` SET `actionTextPasttense` = 'Disapproved' WHERE `actions`.`actionType` = 'disapprove';
UPDATE `actions` SET `actionTextPasttense` = 'Sent Back' WHERE `actions`.`actionType` = 'sendback';


UPDATE `settings` SET `data` = '1597' WHERE `settings`.`setting` = 'dbversion';

COMMIT;