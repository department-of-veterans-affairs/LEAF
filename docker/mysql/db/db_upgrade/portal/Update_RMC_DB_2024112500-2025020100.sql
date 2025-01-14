START TRANSACTION;

INSERT INTO `actions` (`actionType`, `actionText`, `actionTextPasttense`) VALUES
('deleted', 'Cancel', 'Cancelled'),
('move', 'Change Step', 'Changed Step'),
('changeInitiator', 'Change Initiator', 'Changed Initiator');

UPDATE `settings` SET `data` = '2025020100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;