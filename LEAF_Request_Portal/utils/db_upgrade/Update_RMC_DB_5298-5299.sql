START TRANSACTION;

INSERT INTO `portal_testing`.`action_types` (`actionTypeID`, `actionTypeDesc`) VALUES ('9', 'signed');
INSERT INTO `portal_testing`.`action_types` (`actionTypeID`, `actionTypeDesc`) VALUES ('10', 'signature invalidated');

COMMIT;