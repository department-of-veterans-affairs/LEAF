START TRANSACTION;

INSERT INTO `action_types` (`actionTypeID`, `actionTypeDesc`) VALUES ('9', 'signed');
INSERT INTO `action_types` (`actionTypeID`, `actionTypeDesc`) VALUES ('10', 'signature invalidated');

COMMIT;