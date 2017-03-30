START TRANSACTION;
UPDATE `actions` SET `actionIcon` = 'gnome-emblem-default.svg' WHERE `actions`.`actionType` = 'approve';

UPDATE `settings` SET `data` = '1706' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
