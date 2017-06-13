START TRANSACTION;

ALTER TABLE `route_events` ADD UNIQUE (
`workflowID` ,
`stepID` ,
`actionType` ,
`eventID`
);
ALTER TABLE `indicator_mask` ADD UNIQUE (
`indicatorID` ,
`groupID`
);

UPDATE `settings` SET `data` = '3270' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
